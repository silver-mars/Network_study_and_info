kubectl create secret docker-registry (специальный тип секретов, в котором хранятся данные для авторизации различных docker registry) sand-gitlab-registry (имя секрета) (менять это имя не нужно, оно потом будет использоваться для деплоя приложения) --docker-server your.registry.io --docker-email 'yourname@mail' --docker-username 'gitlab+deploy-token' (первая строка в интерфейсе гитлаба, которую он нам выдал после создания деплой-токена) --docker-password 'srme2kxfasdfbkdfsvjoe' (вторая генерируемая строка после созданий деплой-токена) --namespase testus

deploy:
  stage: deploy
  image: centosadmin/kubernetes-helm:3.1.2 // образ, где есть только kubectl and helm
  environment:
    name: production
  script:
    // подключаемся к кластеру
    - kubectl config set-cluster k8s (указываем имя кластера, оно не принципиально) --insecure-skip-tls-verify=tyue --server=$K8S_API_URL (указываем адрес, по которому подключаемся)
    - kubectl config set-credentials ci (создаём юзера) --token=$K8S_CI_TOKEN (Подключаем его с токеном из этой переменной)
    // задаём контекст:
    - kubectl config set-context ci --cluster=k8s (используем кластер, указанный на первом скрипте) --user=ci (и юзера, созданного во втором скрипте)
    // указываем этот контекст как дефолтный:
    - kubectl config use-context ci
    // далее указываем саму команду helm с большим количеством параметров, поскольку мы должны убедиться, что она - идемпотентна.
    - helm upgrade -- install $CI_PROJECT_PATH_SLUG .helm
        --set image=$CI_REGISTRY/$CI_PROJECT_NAMESPACE/$CI_PROJECT_NAME // переопределяем каждый раз
        --set imageTag=$CI_COMMIT_REF_SLUG.$CI_PIPELINE_ID
        --wait // ждать, пока завершится деплой. Пока приложение не примет статус ready.
        --timeout 300s // ждать 300 секунд
        --atomic // атомарный апгрейд. С помощью этого ключа, в случае провала helm самостоятельно запустит rollback.
        --debug // указывает в том числе все сгенерировавшиеся значения в deployment.yaml, etc. jinja2
        --namespace $CI_PROJECT_PATH_SLUG-$CI_ENVIRONMENT_NAME
only:
  - master

Примеры docker-compose:

version: '2.1'
services:
  db:
    image: postgres:9.6
    environment:
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: xpaste_test
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "postgres"]
      interval: 1s
      timeout: 1s
      retries: 60
    logging:
      driver: none

  app:
    image: ${CI_REGISTRY}/${CI_PROJECT_NAMESPACE}/${CI_PROJECT_NAME}:${CI_COMMIT_REF_SLUG}.${CI_PIPELINE_ID}
    // здесь мы указываем, что версия приложения - именно та, которая собралась на стадии build здесь и сейчас.
    environment:
    // Здесь мы пробрасываем внутрь приложения переменные, нужные для подключения к бд и работы самого приложения.
      DB_HOST: db
      DB_PORT: 5432
      DB_USER: postgres
      DB_PASSWORD: postgres
      DB_NAME: xpaste_test
      RAILS_ENV: test
      RAILS_LOG_TO_STDOUT: 1
    command: /bin/sh -c 'bundle exec rake db:migrate && bundle exec rspec spec'
    depends_on:
      db:
        condition: service_healthy

Небольшой разбор гитлаб-сиай файла.

stages:
  - build
  - test
  - cleanup

build:
  stage: build
  before_script:
    - echo $CI_PIPELINE_ID
  script:
    - docker build -t $CI_REGISTRY/$CI_PROJECT_NAMESPACE/$CI_PROJECT_NAME:$CI_COMMIT_REF_SLUG.$CI_PIPELINE_ID .

test:
  stage: test
  image:
    name: docker/compose:1.27.4
    entrypoint: [""]
  script:
    - docker-compose
      # -p - переопределяем имя проекта, используя переменные gitlab'a.
      -p "$CI_PROJECT_NAME"_"$CI_PIPELINE_ID"
      up
      --abort-on-container-exit # нужно, чтобы сама команда docker-compose завершалась тем же exit-кодом,
      --exit-code-from app # что и приложение внутри контейнера app.
      # Таким образом мы сообщаем самому ci-cd pipeline'у что тесты или успешны (0 код) или аварийны.
      --quiet-pull # не показывать лог скачивания контейнеров (слоёв)

cleanup:
  stage: cleanup
  image:
    name: docker/compose:1.27.4
    entrypoint: [""]
  script:
    - docker-compose -p "$CI_PROJECT_NAME"_"$CI_PIPELINE_ID" down
  when: always


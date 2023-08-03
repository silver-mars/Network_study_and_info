#!/bin/bash

base_path=$(dirname $(readlink -f "$0"))
version=$(find "$base_path" -name "u-trans*" | nl)

sudo dpkg --purge u-trans
sudo rm -rf /opt/utm/
echo

echo "Available version:"
echo "$version"
echo "Choose right version for install"
read x
choose=$(find "$base_path" -name "u-trans*" | sed -n ''$x'p')
sudo dpkg -i "$choose"
sudo chown -R $USER:$USER /opt/utm/

# Setting debug logs
debug_file=$(find /opt/utm/transport/lib -name "terminal-backbone-*")

cd "$base_path"
cp "$debug_file" .
jar xf $(basename "$debug_file") logback-spring.xml
search_str=$(grep -n "default,test,prod" logback-spring.xml | cut -d ":" -f 1)
sed -i ''$search_str'a <logger name="ru.centerinform" level="DEBUG" />' logback-spring.xml
jar uf $(basename "$debug_file") logback-spring.xml
cp $(basename "$debug_file") /opt/utm/transport/lib
rm $(basename "$debug_file")
rm logback-spring.xml
echo

base_path=$(dirname $(readlink -f "$0"))/sp
file_sp=$(find /opt/utm/transport/lib/sp-*)

if ! [ -d "$base_path" ]
then
	mkdir $base_path
fi

cp "$file_sp" "$base_path"
cd "$base_path"
jar xf $(basename "$file_sp")
echo "Current contur's settings"
/opt/utm/jre/bin/java -cp /opt/encrypter/lib/"*" ru.centerinform.transport.conf.crypto.Encrypter "$base_path"/sp/sp filter.acquire.address abrakadabra
/opt/utm/jre/bin/java -cp /opt/encrypter/lib/"*" ru.centerinform.transport.conf.crypto.Encrypter "$base_path"/sp/sp | fgrep processing.rest.ws.addres

echo "Choose right contur:"
echo "test"
echo "sand"
echo "none"
#xeyes -center red & // Придумать как проще всего извлекать PID и закрывать его после ввода read.
read x

if [ "$x" == "sand" ]
then
/opt/utm/jre/bin/java -cp /opt/encrypter/lib/"*" ru.centerinform.transport.conf.crypto.Encrypter "$base_path"/sp/sp processing.rest.ws.address http://37.140.197.22:4400/dealer
/opt/utm/jre/bin/java -cp /opt/encrypter/lib/"*" ru.centerinform.transport.conf.crypto.Encrypter "$base_path"/sp/sp processing.rest.ws.address.exchanger http://37.140.197.22:4400/exchanger
elif [ "$x" == "test" ]
then
/opt/utm/jre/bin/java -cp /opt/encrypter/lib/"*" ru.centerinform.transport.conf.crypto.Encrypter "$base_path"/sp/sp processing.rest.ws.address https://test-utm-nd.egais.ru:8443/dealer
/opt/utm/jre/bin/java -cp /opt/encrypter/lib/"*" ru.centerinform.transport.conf.crypto.Encrypter "$base_path"/sp/sp processing.rest.ws.address.exchanger https://test-utm-nd.egais.ru:8443/exchanger
elif [ "$x" == "none" ]
then
	cd ..
	rm -rf sp
	sudo supervisorctl restart utm
	exit
fi
echo "final result:"
/opt/utm/jre/bin/java -cp /opt/encrypter/lib/"*" ru.centerinform.transport.conf.crypto.Encrypter "$base_path"/sp/sp | fgrep processing.rest.ws.address

jar cf $(basename "$file_sp") sp/ META-INF/
sudo cp $(basename "$file_sp") /opt/utm/transport/lib/
cd ..
rm -rf sp
sudo supervisorctl restart utm

Этот раздел необходим для возможности быстро настраивать удобное для работы окружение и все необходимые инструменты.<br>
Список ПО, необходимого для работы и не требующего особенных настроек смотрите [здесь](package_list.md)<br>
Ниже приведён перечень ПО, не входящего в официальные поддерживаемые репозитории debian/ubuntu.<br>

[python and venv](#virtual-environment-for-python)<br>
[visual studio code](#visual-studio)<br>
[helm](#helm)<br>
[fzf](#fzf)<br>
[markdown reader](#markdown-cli-reader)<br>
[vim spelling](#downloading-dictionaries-for-vim-spelling)

## Virtual environment for python
```
WORKSPACE=''
PIP_URL='if_needed'
sudo apt install python3.8 python3.8-venv
python3.8 -m venv venv
source venv/bin/activate
python -m pip install --upgrade --no-cache-dir pip $PIP_URL
pip install -r ${WORKSPACE}/requirements.txt --no-cache-dir
```
## Visual Studio
```
sudo apt install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg
```
Then update the package cache and install the package using:
```
sudo apt install apt-transport-https
sudo apt update
sudo apt install code # or code-insiders
```
Плагины:<br>
**View -> Extensions ->**<vr>
* Python extension for Visual Studio Code<br>

## Helm
```
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt update
sudo apt install helm
```

## FZF
```
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

## Markdown CLI reader
Glow is a terminal based markdown reader for render md in CLI<br>
https://github.com/charmbracelet/glow<br>
```
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
sudo apt update && sudo apt install glow
```
команда в vim для рендеринга не выходя из редактируемого файла:
```
:vert term glow %
```

## Downloading dictionaries for vim spelling
```
mkdir -p ~/.vim/spell/
cd ~/.vim/spell
wget http://ftp.vim.org/vim/runtime/spell/ru.utf-8.sug
wget http://ftp.vim.org/vim/runtime/spell/ru.utf-8.spl
```
(Сами опции настройки есть в .vimrc).

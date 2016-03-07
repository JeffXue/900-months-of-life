if [ ! -d ~/.nvm ];then
    wget https://raw.githubusercontent.com/JeffXue/common_scripts/master/install_nodejs.sh
    chmod +x install_nodejs.sh
    ./install_node.sh
fi

npm install

hexo_path=`pwd`

echo "PATH=$hexo_path/node_modules/hexo/bin:$PATH" >> ~/.profile
export PATH=$hexo_path/node_modules/hexo/bin:$PATH

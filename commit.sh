

param='update';
if [[ $1 ]]; then
	param=$1;
fi

if [[ $param == 'update' ]]; then
	read -p '输入commit说明(默认update):' des;	
	if [[ $des ]]; then
		param=$des;
	fi
fi

git add -A;
git commit -m $param;
git push origin;

hexo c;
hexo g;
hexo d;

echo "commit为：$param";

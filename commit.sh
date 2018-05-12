param='update';
if [[ $1 ]]; then
	param=$1;
fi

git add -A;
git commit -m $param;
git push origin;

hexo c;
hexo g;
hexo d;
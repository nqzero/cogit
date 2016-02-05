# copyright 2016 nqzero, licensed under the MIT license

# cooperative-git-repositories
# defines
#   cogit: function to create aliases for $GIT_DIR
#   git gitk: alias for running gitk with $GIT_DIR

# cogit $name $dir
# set up an alternative git system, ie one based in $dir instead .git
# $dir defaults to .$name
# defines:
#   alias $name=git --git-dir=$PWD/$dir --work-tree=$PWD
#   function $name-chain: chain the corepo with the parent (default .git in the current directory)
# eg,
#   cogit gitx
#   gitx pull
function cogit() {
    name=$1
    dir=${2:-.$name}
    if [[ -z "$name" ]]; then
	echo "usage: cogit aliasName [gitDirectory]"
	echo "  gitDirectory defaults to .aliasName"
	echo "  eg, 'cogit gitx' creates an alias gitx that uses .gitx as the git_dir"
	echo "  uses the current directory (at time of alias creation) as the working directory"
	return
    fi

    # use an alias, instead of a function, to avoid having to worry about expansion
    source /dev/stdin <<- EOF_TOP
	alias ${name}="git --git-dir=$PWD/$dir --work-tree=$PWD"
	EOF_TOP

    source /dev/stdin <<- EOF_TOP
	function ${name}-chain {
	    .cogit-chain $name $dir
	}
	EOF_TOP

}

# chain the repos
# ie, set up a parent/child relationship
#   the child repo records the parent repo HEAD
# semi-private function
function .cogit-chain {

    name=$1
    dir=${2:-.$name}
    data=${dir}-data

    if [[ ! -d $dir ]]; then
	echo -n "git_dir not found ... "
	git --git-dir=$PWD/$dir --work-tree=$PWD init
    fi


    mkdir -p $data

    cat <<- EOF_commit > $data/pre-commit
	#!/bin/bash
	file=\${GIT_DIR}-data/cogit-head.txt
	git --git-dir=.git rev-parse HEAD > \$file
	git add -f \$file

	EOF_commit

    chmod u+x $data/pre-commit
    ln -s ../../$data/pre-commit $dir/hooks
}

# set up a git alias so 'gitx gitk' will see the $GIT_DIR
if [ -z "$(git config alias.gitk)" ]; then
    git config --global alias.gitk '!gitk'
fi


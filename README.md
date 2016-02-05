# cogit
use multiple git repositories in a single working directory

# the problem
some code naturally belongs to more than one repository,
or code from multiple repositories need to coexist in a single working directory.
eg:
- in the process of writing a larger tool, a single file is developed that you want to publish independently on github
- a project has public and private components, interspersed in a number of shared directories
- a project has classified and unclassified components, inersprersed in a number of shared directories

by default, git doesn't handle this case well.
some common workarounds are:
- git submodules
- git subtree
in some cases these tools work well but somewhat complicate the workflow
and still require that the code be split up into independent subdirectories.


# a simple hack
cogit is a shell script that defines an alias to simplify using multiple git repos in a common working directory.
it's equivalent to using `--git-dir` arguments


## usage - creating a new repo
```
# create newrepo on github
source cogit.sh # possibly in .bashrc
cd ~/working/dir
cogit gitx
gitx init
gitx add some_files
gitx commit -m "first cogit commit"
gitx remote add origin git@github.com:username/newrepo.git
gitx branch -u origin/master master
gitx push
```

## cloning an existing repo
`git clone` doesn't seem to honor these settings and won't clone to a non-empty directory,
so explicitly set the git directory
```
cogit gitx
git clone -n --bare git@github.com:username/oldrepo.git .gitx
gitx checkout -- .
```


## chaining
in one workflow, the working directory is part of an existing git repo.
it can be convenient to track the relationship between this parent directory and the new corepo.

`gitx-chain` will install git hooks to store the parent repo HEAD commit in `.gitx-data/cogit-head.txt`.


## gitignore
git honors `.gitignore` so if a parent repo is using it, you'll have to manually add anything that's ignored.
you can define corepo-specific ignores using the exclude file, eg `.gitx/info/exclude`.
you may want to link to the chained data directory (this may get added to gitx-chain eventually)
```
gitx-chain
mv .gitx/info/exlude .gitx-data
ln -s ../../.gitx-data/exlude .gitx/info
gitx add .gitx-data/exclude
```

# other uses
any time you'd like to use a `GIT_DIR` other than the default, this tool can simplify usage.
eg, to put your home directory under version control
```
cd ~
cogit gitx
gitx init
...
```





## copyright 2016 nqzero

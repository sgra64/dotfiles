# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Checkout dotfiles in HOME-directory
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

cd $HOME

git init
git remote add origin git@github.com:sgra64/dotfiles.git

# pull 'main'-branch with latest dotfiles release (alt. pull 'dev'-branch)
git pull origin main

# remove 'README.md' from HOME-directory
git rm README.md
git commit -m "remove README.md"

# -------------
# helpers for git dev
# -------------

# git checkout branch and pull, set b=<branch>
g.switch-pull:
	git switch $(b)
	git fetch --prune origin
	git pull

g.dev.switch-pull:
	make g.switch-pull b=dev

g.master.switch-pull:
	make g.switch-pull b=master

g.branch.new:
	read -p "branch name: " bname
	git switch -c "$$bname"

# adds all changes, commits and push
g.commit.push:
	git status
	echo "---------------------------------------------------------------"
	echo "The Unstaged and Untracked files above will be added to commit."
	echo "Enter a commit message"
	read -p ":" msg
	git add -A
	git commit -m "$$msg"
	# -u @ does the work of creating branch on github if it doesnt exist
	git push origin -u @

# new pull request for current branch against dev
g.pr.new:
	hub pull-request -o -b dev

# pull request for current branch.
g.pr.show:
	hub pr show

# creates new master-dev-merge branch and opens pr
g.master-dev-merge:
	git switch master
	git pull
	git switch -c master-dev-merge
	git merge --no-commit --no-ff dev
	git commit -m "merged dev"
	git push origin -u @
	# create pr and open page
	hub pull-request -o --base master -m "dev master merge"

# resets dev to be at master, run after done releasing
g.master-dev-reset:
	git switch master
	git fetch --prune origin
	git pull
	git switch dev
	# back up dev
	git pull
	git switch -c "dev-$$(date "+%Y-%m-%d")"
	# switch back to dev
	git switch dev
	git reset --hard origin/master
	git fetch origin
	git pull --no-commit --no-rebase --no-ff origin dev
	git commit -m "hard reset to master HEAD"
	git push origin refs/heads/dev:refs/heads/dev

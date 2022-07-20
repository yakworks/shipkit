# -------------
# helpers for git dev
# -------------

## show help for GIT and GITHUB short cut helpers, alias to help.git
g.help: help.git

## show help for GIT and GITHUB short cut helpers
help.git:
	$(MAKE) help HELP_REGEX="^g[\.]+.*"


# git checkout branch and pull, b=<branch>
g.switch-pull:
	git switch $(b)
	git fetch --prune origin
	git pull

# git switch to dev branch and pull
g.dev.switch-pull:
	$(MAKE) g.switch-pull b=dev

# switch to master and pull
g.master.switch-pull:
	$(MAKE) g.switch-pull b=master

# prompt for a new branch to create then switch to it after creation
g.branch.new:
	read -p "branch name: " bname
	git switch -c "$$bname"

# adds all changes, commits and push. Will prompt for commit message if there are changes.
g.commit:
	git status
	echo "---------------------------------------------------------------"
	echo "The Unstaged and Untracked files above will be added to commit."
	echo "Enter a commit message"
	read -p ":" msg
	git add -A
	git commit -m "$$msg"
	# -u @ does the work of creating branch on github if it doesnt exist
	git push origin -u @

g.commit.pr: g.commit g.pr.new

# new pull request for current branch against dev
g.pr.new:
	if [ "$(b)" ]; then
		hub pull-request -o --no-edit $(pr_opts) -b $(b)
	else
		hub pull-request -o --no-edit $(pr_opts)
	fi

g.pr.draft: pr_opts = -d
g.pr.draft: g.pr.new

# list pull request
g.pr.list:
	gh pr list

# WIP creates new master-dev-merge branch and opens pr
g.master-dev-merge:
	git switch master
	git pull
	git switch -c master-dev-merge
	git merge --no-commit --no-ff dev
	git commit -m "merged dev"
	git push origin -u @
	# create pr and open page
	hub pull-request -o --base master -m "dev master merge"

# WIP resets dev to be at master, run after done releasing
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

# checks for changes
g.check-changes:
	changed_files=$$(git status --porcelain --untracked-files=no | wc -l)
	unpushed=$$(git cherry -v)
	if [ $$changed_files -gt 0 ] || [ "$$unpushed" ] ; then
		$(logr.error) "uncommitted changes detected. must be in a clean state"
		git status
		exit 1 # not 0 so considred error and should halt
	fi

# update release=true in version.properties and pushes the changes.
g.update-release: GITHUB_BOT_URL = https://dummy:$(GITHUB_BOT_TOKEN)@github.com/$(PROJECT_FULLNAME).git
g.update-release: VERSION_FILE = version.properties
g.update-release:
	sed -i.bak -e "s/^release=.*/release=true/g" $(VERSION_FILE) && rm "$(VERSION_FILE).bak"
	git add $(VERSION_FILE)
	git commit -m "trigger release"
	git push $(GITHUB_BOT_URL)
	$(logr.done)

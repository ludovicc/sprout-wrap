include_recipe "pivotal_workstation::git"
pivotal_workstation_bash_it_custom_plugin "git-export_editor.bash"

template "#{WS_HOME}/.gitignore_global" do
  source "gitignore_global.erb"
  owner WS_USER
  variables(:ignore_idea => node[:git_global_ignore_idea])
end

execute "set global git ignore" do
  command "git config --global core.excludesfile #{WS_HOME}/.gitignore_global"
  user WS_USER
  only_if "[ -z `git config --global core.excludesfile` ]"
end

execute "make the pager prettier" do
  # When paging to less:
  # * -x2 Tabs appear as two spaces
  # * -S Chop long lines
  # * -F Don't require interaction if paging less than a full screen
  # * -X No scren clearing
  # * -R Raw, i.e. don't escape the control characters that produce colored output
  command %{git config --global core.pager "less -FXRS -x2"}
  user WS_USER
end

# http://durdn.com/blog/2012/11/22/must-have-git-aliases-advanced-examples/
# http://pioupioum.fr/developpement/git-alias-productivite.html

aliases =<<EOF
#############
# Basic aliases
b branch
c checkout
co checkout
ci commit
p push
u \"pull --rebase\"
s \"status -sb\"
who \"shortlog -sne\"
d  \"diff -b\"
dc \"diff -b --cached\"
ds \"diff -b --stat\"
#############
# Local changes
# Undo last commit
undo \"git reset --soft HEAD^\"
# Edit last commit
amend \"commit --amend -C HEAD\"
#############
# Reset commands
r \"reset\"
r1 \"reset HEAD^\"
r2 \"reset HEAD^^\"
rh \"reset --hard\"
rh1 \"reset HEAD^ --hard\"
rh2 \"reset HEAD^^ --hard\"
#############
# Stash operations
sa \"stash apply\"
ss \"stash save\"
sl \"stash list\"
#############
# TODO: undocumented
last \"cat-file commit HEAD\"
# summary of what you're going to push
ps \"log --pretty=oneline origin..master\"
# like "git log", but include the diffs
w \"whatchanged -p\"
# changes since we last did a push
wo \"whatchanged -p origin..\"
# Show files ignored by git:
ignored-files \"ls-files -o -i --exclude-standard\"
# Lists commits with deleted files
deleted-files \"log --diff-filter=D --summary\"
ds \"diff --staged\"
fixup    \"commit --fixup\"
squash   \"commit --squash\"
unstage  \"reset HEAD\"
rum      \"rebase master@{u}\"
#############
# Explore your history, the commits and the code
# Shorten and beautify your log command because you will use it a lot. I have a ton of list(ls) and inspection commands that I use constantly. I recommend you experiment with the examples below and come up with your own variation. I type git ls and git ll several dozens of times a day.
# List commits in short form, with colors and branch/tag annotations. My bread and butter log command is invoked with git ls and looks like this:
ls \"log --pretty=format:\\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\\" --decorate\"
# List commits showing changed files is invoked with git ll:
ll \"log --pretty=format:\\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\\" --decorate --numstat\"
# List with no colors if you need to chain the out put with Unix pipes:
lnc \"log --pretty=format:\\"%h\\ %s\\ [%cn]\\"\"
# List oneline commits showing dates:
lds \"log --pretty=format:\\"%C(yellow)%h\\\\ %ad%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\\" --decorate --date=short\"
# List oneline commits showing relative dates:
ld \"log --pretty=format:\\"%C(yellow)%h\\\\ %ad%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\\" --decorate --date=relative\"
# Default look for short git log:
le \"log --oneline --decorate\"
# TODO: undocumented
llog \"log --date=local\"
# TODO: undocumented
flog \"log --pretty=fuller --decorate\"
# TODO: undocumented
lol \"log --graph --decorate --oneline\"
# TODO: undocumented
lola \"log --graph --decorate --oneline --all\"
# TODO: undocumented
blog \"log origin/master... --left-right\"
# TODO: undocumented
lg \"log --graph --all --pretty=format:'%Cred%h%Creset - %Cgreen(%cr)%Creset %s%C(yellow)%d%Creset %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative\"
# log the differences from the origin
rlog \"log origin/master..HEAD --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative\"
# TODO: undocumented
show-graph \"log --graph --abbrev-commit --pretty=oneline\"
#############
# Show the history of a file, with diffs
# You can see all the commits related to a file, with the diff of the changes withgit log -u which i shortened to fl for filelog:
filelog \"log -ufl = log -u\"
#############
# Find all commits where commit message contains given word
grep-msg \"!f() { git log --grep="$1"; }; f\"
#############
# Log commands to inspect (recent) history
# Show modified files in last commit:
dl \"!git ll -1\"
# Show a diff last commit:
dlc \"diff --cached HEAD^\"
# Show content (full diff) of a commit given a revision:
dr \"!f() { git diff "$1"^.."$1"; }; f\"
lc \"!f() { git ll "$1"^.."$1"; }; f\"
diffr \"!f() { git diff "$1"^.."$1"; }; f\"
#############
# Finding files and content inside files (grep)
# Find a file path in codebase:
# Example usage: git f web.xml
f \"!git ls-files | grep -i\"
# Search/grep your entire codebase for a string:
# Example usage: git gr TODO
grep \"grep -I\"
igr \"grep -Ii\"
# Grep from root folder:
gra \"!f() { A=$(pwd) && TOPLEVEL=$(git rev-parse --show-toplevel) && cd $TOPLEVEL && git grep --full-name -In $1 | xargs -I{} echo $TOPLEVEL/{} && cd $A; }; f\"
#############
# List all your Aliases (la)
la \"!git config -l | grep alias | cut -c 7-\"
#############
# Rename [branch] to done-[branch]
done \"!f() { git branch | grep "$1" | cut -c 3- | grep -v done | xargs -I{} git branch -m {} done-{}; }; f\"
#############
# Assume aliases - do not commit fileds under version control
# Assume a file as unchanged
assume   \"update-index --assume-unchanged\"
# Unassume a file:
unassume \"update-index --no-assume-unchanged\"
# Show assumed files:
assumed  \"!git ls-files -v | grep ^h | cut -c 3-\"
# Unassume all the assumed files:
unassumeall \"!git assumed | xargs git update-index --no-assume-unchanged\"
# Assume all:
assumeall \"!git st -s | awk {'print $2'} | xargs git assume\"
#############
snapshot \"!git stash save \\\"snapshot: \\\$(date)\\\" && git stash apply \\\"stash@{0}\\\"\"
#############
# Tag aliases
# Show the last Tag
lasttag \"describe --tags --abbrev=0\"
lt \"describe --tags --abbrev=0\"
#############
# Merge aliases
ours     \"!f() { git checkout --ours $@ && git add $@; }; f\"
theirs   \"!f() { git checkout --theirs $@ && git add $@; }; f\"
EOF

# TODO
# lc = !git oneline ORIG_HEAD.. --stat --no-merges
#    addm = !git-ls-files -m -z | xargs -0 git-add && git status
#    addu = !git-ls-files -o --exclude-standard -z | xargs -0 git-add && git status
#    rmm = !git ls-files -d -z | xargs -0 git-rm && git status
#    mate = !git-ls-files -m -z | xargs -0 mate
#    mateall = !git-ls-files -m -o --exclude-standard -z | xargs -0 mate

aliases.split("\n").reject{|s| s =~ /^#/}.each do |alias_string|
  abbrev = alias_string.split[0]
  execute "set alias #{abbrev}" do
    command "git config --global alias.#{alias_string}"
    user WS_USER
    only_if "[ -z `git config --global alias.#{abbrev}` ]"
  end
end

execute "set apply whitespace=nowarn" do
  command "git config --global apply.whitespace nowarn"
  user WS_USER
end

execute "set color branch=auto" do
  command "git config --global color.branch auto"
  user WS_USER
end

execute "set color diff=auto" do
  command "git config --global color.diff auto"
  user WS_USER
end

execute "set color interactive=auto" do
  command "git config --global color.interactive auto"
  user WS_USER
end

execute "set color status=auto" do
  command "git config --global color.status auto"
  user WS_USER
end

execute "set color ui=auto" do
  command "git config --global color.ui auto"
  user WS_USER
end

execute "set branch autosetupmerge=true" do
  command "git config --global branch.autosetupmerge true"
  user WS_USER
end

execute "set rebase autosquash=true" do
  command "git config --global rebase.autosquash true"
  user WS_USER
end

execute "set diff algorithm=patience" do
    command "git config --global diff.algorithm patience"
    user WS_USER
end

execute "set push default=simple" do
    command "git config --global push.default simple"
    user WS_USER
end

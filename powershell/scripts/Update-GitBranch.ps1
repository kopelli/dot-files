Function Update-GitBranch {
    [CmdletBinding()]
    param(
        [switch]
        $Interactive,

        [string]
        $Branch
    )
    begin {
    }
    process {
        # On the remote, the following refs:
        #  - HEAD
        #  - refs/heads/<branch name>
        #  - refs/pull/<pull request #>/head
        #  - refs/tags/<tag name ... with / >

        # git init <directory>
        # git fetch --no-tags --force --progress --depth=1 -- <Repo URL> +refs/heads/*:refs/remotes/origin/*
        # git config remote.origin.url <Repo URL>
        # git config --add remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
        # git config remote.origin.url <Repo URL>
        # git rev-parse --verify HEAD
        # git clean -ffdx
        # git fetch --no-tags --force --progress --depth=1 -- <Repo URL> +refs/pull/3103/head:refs/remotes/origin/PR-3103

        # git fetch --all
        # default upstream branch name = $(git symbolic-ref refs/remotes/origin/HEAD --short)
        # git rebase --committer-date-is-author-date --no-update-refs $Default-Upstream-Branch-Name
    }
}
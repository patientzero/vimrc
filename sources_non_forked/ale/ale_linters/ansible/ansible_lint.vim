" Authors: Bjorn Neergaard <bjorn@neersighted.com>, Vytautas Macionis <vytautas.macionis@manomail.de>
" Description: ansible-lint for ansible-yaml files

call ale#Set('ansible_ansible_lint_executable', 'ansible-lint')

function! ale_linters#ansible#ansible_lint#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'ansible_ansible_lint_executable')
endfunction

function! ale_linters#ansible#ansible_lint#Handle(buffer, version, lines) abort
    for l:line in a:lines[:10]
        if match(l:line, '^Traceback') >= 0
            return [{
            \   'lnum': 1,
            \   'text': 'An exception was thrown. See :ALEDetail',
            \   'detail': join(a:lines, "\n"),
            \}]
        endif
    endfor

<<<<<<< HEAD
    let l:version_group = ale#semver#GTE(a:version, [5, 0, 0]) ? '>=5.0.0' : '<5.0.0'
    let l:output = []

    if '>=5.0.0' is# l:version_group
        " Matches patterns line the following:
        "      test.yml:3:148: syntax-check 'var' is not a valid attribute for a Play
        "      roles/test/tasks/test.yml:8: [package-latest] [VERY_LOW] Package installs should not use latest
        "      D:\test\tasks\test.yml:8: [package-latest] [VERY_LOW] package installs should not use latest
        let l:pattern = '\v^(%([a-zA-Z]:)?[^:]+):(\d+):%((\d+):)? %(\[([-[:alnum:]]+)\]) %(\[([_[:alnum:]]+)\]) (.*)$'
        let l:error_codes = { 'VERY_HIGH': 'E', 'HIGH': 'E', 'MEDIUM': 'W', 'LOW': 'W', 'VERY_LOW': 'W', 'INFO': 'I' }

        for l:match in ale#util#GetMatches(a:lines, l:pattern)
            if ale#path#IsBufferPath(a:buffer, l:match[1])
                call add(l:output, {
                \   'lnum': l:match[2] + 0,
                \   'col': l:match[3] + 0,
                \   'text': l:match[6],
                \   'code': l:match[4],
                \   'type': l:error_codes[l:match[5]],
                \})
            endif
        endfor
    endif

=======
    let l:version_group = ale#semver#GTE(a:version, [6, 0, 0]) ? '>=6.0.0' :
    \                     ale#semver#GTE(a:version, [5, 0, 0]) ? '>=5.0.0' :
    \                     '<5.0.0'
    let l:output = []

    if '>=6.0.0' is# l:version_group
        let l:error_codes = { 'blocker': 'E', 'critical': 'E', 'major': 'W', 'minor': 'W', 'info': 'I' }
        let l:linter_issues = ale#util#FuzzyJSONDecode(a:lines, [])

        for l:issue in l:linter_issues
            if ale#path#IsBufferPath(a:buffer, l:issue.location.path)
                if exists('l:issue.location.positions')
                    let l:coord_keyname = 'positions'
                else
                    let l:coord_keyname = 'lines'
                endif

                let l:column_member = printf(
                \    'l:issue.location.%s.begin.column', l:coord_keyname
                \)

                call add(l:output, {
                \   'lnum': exists(l:column_member) ? l:issue.location[l:coord_keyname].begin.line :
                \           l:issue.location[l:coord_keyname].begin,
                \   'col': exists(l:column_member) ? l:issue.location[l:coord_keyname].begin.column : 0,
                \   'text': l:issue.check_name,
                \   'detail': l:issue.description,
                \   'code': l:issue.severity,
                \   'type': l:error_codes[l:issue.severity],
                \})
            endif
        endfor
    endif

    if '>=5.0.0' is# l:version_group
        " Matches patterns line the following:
        "      test.yml:3:148: syntax-check 'var' is not a valid attribute for a Play
        "      roles/test/tasks/test.yml:8: [package-latest] [VERY_LOW] Package installs should not use latest
        "      D:\test\tasks\test.yml:8: [package-latest] [VERY_LOW] package installs should not use latest
        let l:pattern = '\v^(%([a-zA-Z]:)?[^:]+):(\d+):%((\d+):)? %(\[([-[:alnum:]]+)\]) %(\[([_[:alnum:]]+)\]) (.*)$'
        let l:error_codes = { 'VERY_HIGH': 'E', 'HIGH': 'E', 'MEDIUM': 'W', 'LOW': 'W', 'VERY_LOW': 'W', 'INFO': 'I' }

        for l:match in ale#util#GetMatches(a:lines, l:pattern)
            if ale#path#IsBufferPath(a:buffer, l:match[1])
                call add(l:output, {
                \   'lnum': l:match[2] + 0,
                \   'col': l:match[3] + 0,
                \   'text': l:match[6],
                \   'code': l:match[4],
                \   'type': l:error_codes[l:match[5]],
                \})
            endif
        endfor
    endif

>>>>>>> refs/remotes/origin/master
    if '<5.0.0' is# l:version_group
        " Matches patterns line the following:
        "      test.yml:35: [EANSIBLE0002] Trailing whitespace
        let l:pattern = '\v^([a-zA-Z]?:?[^:]+):(\d+):?(\d+)?: \[?([[:alnum:]]+)\]? (.*)$'

        for l:match in ale#util#GetMatches(a:lines, l:pattern)
            let l:code = l:match[4]

            if l:code is# 'EANSIBLE0002'
            \&& !ale#Var(a:buffer, 'warn_about_trailing_whitespace')
                " Skip warnings for trailing whitespace if the option is off.
                continue
            endif

            if ale#path#IsBufferPath(a:buffer, l:match[1])
                call add(l:output, {
                \   'lnum': l:match[2] + 0,
                \   'col': l:match[3] + 0,
                \   'text': l:match[5],
                \   'code': l:code,
                \   'type': l:code[:0] is# 'E' ? 'E' : 'W',
                \})
            endif
        endfor
    endif

    return l:output
endfunction

function! ale_linters#ansible#ansible_lint#GetCommand(buffer, version) abort
    let l:commands = {
<<<<<<< HEAD
    \   '>=5.0.0': '%e --nocolor --parseable-severity -x yaml %s',
    \   '<5.0.0': '%e --nocolor -p %t'
    \}
    let l:command = ale#semver#GTE(a:version, [5, 0]) ? l:commands['>=5.0.0'] : l:commands['<5.0.0']
=======
    \   '>=6.0.0': '%e --nocolor -f json -x yaml %s',
    \   '>=5.0.0': '%e --nocolor --parseable-severity -x yaml %s',
    \   '<5.0.0': '%e --nocolor -p %t'
    \}
    let l:command = ale#semver#GTE(a:version, [6, 0]) ? l:commands['>=6.0.0'] :
    \               ale#semver#GTE(a:version, [5, 0]) ? l:commands['>=5.0.0'] :
    \               l:commands['<5.0.0']
>>>>>>> refs/remotes/origin/master

    return l:command
endfunction

call ale#linter#Define('ansible', {
\   'name': 'ansible_lint',
\   'aliases': ['ansible', 'ansible-lint'],
\   'executable': function('ale_linters#ansible#ansible_lint#GetExecutable'),
\   'command': {buffer -> ale#semver#RunWithVersionCheck(
\       buffer,
\       ale_linters#ansible#ansible_lint#GetExecutable(buffer),
\       '%e --version',
\       function('ale_linters#ansible#ansible_lint#GetCommand'),
\   )},
\   'lint_file': 1,
\   'callback': {buffer, lines -> ale#semver#RunWithVersionCheck(
\       buffer,
\       ale_linters#ansible#ansible_lint#GetExecutable(buffer),
\       '%e --version',
\       {buffer, version -> ale_linters#ansible#ansible_lint#Handle(
\           buffer,
\           l:version,
\           lines)},
\   )},
\})

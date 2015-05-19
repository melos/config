set nocompatible
filetype off

"OSの種類をOSTYPEに格納（OS別の設定に使用）
let OSTYPE  =  system('uname')

"改行コードは set fileformat=unix に設定するとunixでも使えます。

"Windowsで内部エンコーディングを cp932以外にしていて、
"環境変数に日本語を含む値を設定したい場合は Let を使用します。
"Letは vimrc(オールインワンパッケージの場合)と encode.vim で定義されます。
"Let $HOGE=$USERPROFILE.'/ほげ'

"----------------------------------------
" ユーザーランタイムパス設定
"----------------------------------------
"Windows, unixでのruntimepathの違いを吸収するためのもの。
"$MY_VIMRUNTIMEはユーザーランタイムディレクトリを示す。
":echo $MY_VIMRUNTIMEで実際のパスを確認できます。
if isdirectory($HOME . '/.vim')
  let $MY_VIMRUNTIME = $HOME.'/.vim'
elseif isdirectory($HOME . '\vimfiles')
  let $MY_VIMRUNTIME = $HOME.'\vimfiles'
elseif isdirectory($VIM . '\vimfiles')
  let $MY_VIMRUNTIME = $VIM.'\vimfiles'
endif

"ランタイムパスを通す必要のあるプラグインを使用する場合、
"$MY_VIMRUNTIMEを使用すると Windows/Linuxで切り分ける必要が無くなります。
"例) vimfiles/qfixapp (Linuxでは~/.vim/qfixapp)にランタイムパスを通す場合
"set runtimepath+=$MY_VIMRUNTIME/qfixapp

"----------------------------------------
" 内部エンコーディング指定
"----------------------------------------
"内部エンコーディングのUTF-8化と文字コードの自動認識設定をencode.vimで行う。
"オールインワンパッケージの場合 vimrcで設定されます。
"エンコーディング指定や文字コードの自動認識設定が適切に設定されている場合、
"次行の encode.vim読込部分はコメントアウトして下さい。
silent! source $MY_VIMRUNTIME/pluginjp/encode.vim
"scriptencodingと異なる内部エンコーディングに変更する場合、
"変更後にもscriptencodingを指定しておくと問題が起きにくくなります。
"scriptencodingと、このファイルのエンコーディングが一致するよう注意！
"scriptencodingは、vimの内部エンコーディングと同じものを推奨します。
scriptencoding cp932

"----------------------------------------
"文字コードの自動認識
"----------------------------------------
if &encoding !=# 'utf-8'
  set encoding=japan
  set fileencoding=japan
endif
if has('iconv')
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'
  "iconvがeucJP-msに対応しているかをチェック
  if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'eucjp-ms'
    let s:enc_jis = 'iso-2022-jp-3'
  "iconvがJISX0213に対応しているかをチェック
  elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'euc-jisx0213'
    let s:enc_jis = 'iso-2022-jp-3'
  endif
  "fileencodingsを構築
  if &encoding ==# 'utf-8'
    let s:fileencodings_default = &fileencodings
    let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
    let &fileencodings = &fileencodings .','. s:fileencodings_default
    unlet s:fileencodings_default
  else
    let &fileencodings = &fileencodings .','. s:enc_jis
    set fileencodings+=utf-8,ucs-2le,ucs-2
    if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
      set fileencodings+=cp932
      set fileencodings-=euc-jp
      set fileencodings-=euc-jisx0213
      set fileencodings-=eucjp-ms
      let &encoding = s:enc_euc
      let &fileencoding = s:enc_euc
    else
      let &fileencodings = &fileencodings .','. s:enc_euc
    endif
  endif
  "定数を処分
  unlet s:enc_euc
  unlet s:enc_jis
endif
"日本語を含まない場合は fileencoding に encoding を使うようにする
if has('autocmd')
  function! AU_ReCheck_FENC()
    if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
      let &fileencoding=&encoding
    endif
  endfunction
  autocmd BufReadPost * call AU_ReCheck_FENC()
endif
"改行コードの自動認識
set fileformats=unix,dos,mac

"----------------------------------------
" システム設定
"----------------------------------------
"mswin.vimを読み込む
"source $VIMRUNTIME/mswin.vim
"behave mswin

"ファイルの上書きの前にバックアップを作る/作らない
"set writebackupを指定してもオプション 'backup' がオンでない限り、
"バックアップは上書きに成功した後に削除される。
set nowritebackup
"バックアップ/スワップファイルを作成する/しない
set nobackup
if version >= 703
  "再読込、vim終了後も継続するアンドゥ(7.3)
  "set undofile
  "アンドゥの保存場所(7.3)
  "set undodir=.
endif
set noswapfile
"viminfoを作成しない
"set viminfo=
"クリップボードを共有
set clipboard+=unnamed
"貼り付けた時に階段上にならなくする
imap <F11> <nop>
set pastetoggle=<F11>
"8進数を無効にする。<C-a>,<C-x>に影響する
set nrformats-=octal
"キーコードやマッピングされたキー列が完了するのを待つ時間(ミリ秒)
set timeoutlen=3500
"編集結果非保存のバッファから、新しいバッファを開くときに警告を出さない
set hidden
"ヒストリの保存数
set history=200
"日本語の行の連結時には空白を入力しない
set formatoptions+=mM
"Visual blockモードでフリーカーソルを有効にする
set virtualedit=block
"カーソルキーで行末／行頭の移動可能に設定
set whichwrap=b,s,[,],<,>
"バックスペースでインデントや改行を削除できるようにする
set backspace=indent,eol,start
"□や○の文字があってもカーソル位置がずれないようにする
set ambiwidth=double
"コマンドライン補完するときに強化されたものを使う
set wildmenu
"マウスを有効にする
if has('mouse')
  set mouse=a
endif
"pluginを使用可能にする
filetype plugin indent on

"----------------------------------------
" 検索
"----------------------------------------
"検索の時に大文字小文字を区別しない
"ただし大文字小文字の両方が含まれている場合は大文字小文字を区別する
set ignorecase
set smartcase
"検索時にファイルの最後まで行ったら最初に戻る
set wrapscan
"インクリメンタルサーチ
set incsearch
"検索文字の強調表示
set hlsearch
"w,bの移動で認識する文字
set iskeyword=a-z,A-Z,48-57,_,.,-,>
"vimgrep をデフォルトのgrepとする場合internal
"set grepprg=internal

"----------------------------------------
" 表示設定
"----------------------------------------
"スプラッシュ(起動時のメッセージ)を表示しない
set shortmess+=I
"エラー時の音とビジュアルベルの抑制(gvimは.gvimrcで設定)
set noerrorbells
set novisualbell
set visualbell t_vb=
"マクロ実行中などの画面再描画を行わない
"set lazyredraw
"Windowsでディレクトリパスの区切り文字表示に / を使えるようにする
set shellslash
"行番号表示
set number
"if version >= 703
  "相対行番号表示(7.3)
  "set relativenumber
"endif
"行の折り返し表示をしない
set nowrap
"括弧の対応表示時間
set showmatch matchtime=1
"タブを設定
set ts=2 sw=2 sts=2
"インデントを設定
set shiftwidth=2
"自動的にインデントする
set autoindent
"タブ入力を半角スペースに変換する
set expandtab
"Cインデントの設定
set cinoptions+=:0
"タイトルを表示
set title
"コマンドラインの高さ (gvimはgvimrcで指定)
set cmdheight=2
set laststatus=2
"コマンドをステータス行に表示
set showcmd
"画面最後の行をできる限り表示する
set display=lastline
"Tab、行末の半角スペースを明示的に表示する
set list
set listchars=tab:^\ ,trail:~
"カレント行のハイライト（色の反転）
set cursorline
set cursorcolumn
highlight cursorline term=reverse cterm=reverse
highlight cursorcolumn term=reverse cterm=reverse
"色テーマ設定
colorscheme molokai
"２５６色モードにする
set t_Co=256

""""""""""""""""""""""""""""""
"ステータスラインに文字コード等表示
"iconvが使用可能の場合、カーソル上の文字コードをエンコードに応じた表示にするFencB()を使用
""""""""""""""""""""""""""""""
if has('iconv')
  set statusline=%<%f\ %m\ %r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=[0x%{FencB()}]\ (%v,%l)/%L%8P\ 
else
  set statusline=%<%f\ %m\ %r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=\ (%v,%l)/%L%8P\ 
endif

"FencB() : カーソル上の文字コードをエンコードに応じた表示にする
function! FencB()
  let c = matchstr(getline('.'), '.', col('.') - 1)
  let c = iconv(c, &enc, &fenc)
  return s:Byte2hex(s:Str2byte(c))
endfunction

function! s:Str2byte(str)
  return map(range(len(a:str)), 'char2nr(a:str[v:val])')
endfunction

function! s:Byte2hex(bytes)
  return join(map(copy(a:bytes), 'printf("%02X", v:val)'), '')
endfunction

"----------------------------------------
" diff/patch
"----------------------------------------
"diffの設定
if has('win32') || has('win64')
  set diffexpr=MyDiff()
  function! MyDiff()
    let opt = '-a --binary '
    if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
    if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
    let arg1 = v:fname_in
    if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
    let arg2 = v:fname_new
    if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
    let arg3 = v:fname_out
    if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
    let cmd = '!diff ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
    silent execute cmd
  endfunction
endif

"現バッファの差分表示(変更箇所の表示)
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
"ファイルまたはバッファ番号を指定して差分表示。#なら裏バッファと比較
command! -nargs=? -complete=file Diff if '<args>'=='' | browse vertical diffsplit|else| vertical diffsplit <args>|endif
"パッチコマンド
set patchexpr=MyPatch()
function! MyPatch()
   :call system($VIM."\\'.'patch -o " . v:fname_out . " " . v:fname_in . " < " . v:fname_diff)
endfunction

"----------------------------------------
" ノーマルモード
"----------------------------------------
"ヘルプ検索
nnoremap <F1> K
"現在開いているvimスクリプトファイルを実行
nnoremap <F8> :source %<CR>
"強制全保存終了を無効化
nnoremap ZZ <Nop>
"カーソルをj k では表示行で移動する。物理行移動は<C-n>,<C-p>
"キーボードマクロには物理行移動を推奨
"h l は行末、行頭を超えることが可能に設定(whichwrap)
nnoremap <Down> gj
nnoremap <Up>   gk
nnoremap h <Left>
nnoremap j gj
nnoremap k gk
nnoremap l <Right>
"l を <Right>に置き換えても、折りたたみを l で開くことができるようにする
if has('folding')
  nnoremap <expr> l foldlevel(line('.')) ? "\<Right>zo" : "\<Right>"
endif
"emacs の follow mode もどき
nnoremap <silent> <Leader>ef  :vsplit<bar>wincmd l<bar>exe "norm! Ljz<c-v><cr>"<cr>:set scb<cr>:wincmd h<cr>:set scb<cr>

"----------------------------------------
" 挿入モード
"----------------------------------------
"jjでESC
inoremap <silent> jj <ESC>

"----------------------------------------
" ビジュアルモード
"----------------------------------------

"----------------------------------------
" コマンドモード
"----------------------------------------

"----------------------------------------
" Vimスクリプト
"----------------------------------------
""""""""""""""""""""""""""""""
"ファイルを開いたら前回のカーソル位置へ移動
"$VIMRUNTIME/vimrc_example.vim
""""""""""""""""""""""""""""""
augroup vimrcEx
  autocmd!
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line('$') |
    \   exe "normal! g`\"" |
    \ endif
augroup END

""""""""""""""""""""""""""""""
"挿入モード時、ステータスラインのカラー変更
""""""""""""""""""""""""""""""
let g:hi_insert = 'highlight StatusLine guifg=darkblue guibg=darkyellow gui=none ctermfg=blue ctermbg=yellow cterm=none'

if has('syntax')
  augroup InsertHook
    autocmd!
    autocmd InsertEnter * call s:StatusLine('Enter')
    autocmd InsertLeave * call s:StatusLine('Leave')
  augroup END
endif
" if has('unix') && !has('gui_running')
"   " ESCですぐに反映されない対策
"   inoremap <silent> <ESC> <ESC>
" endif

let s:slhlcmd = ''
function! s:StatusLine(mode)
  if a:mode == 'Enter'
    silent! let s:slhlcmd = 'highlight ' . s:GetHighlight('StatusLine')
    silent exec g:hi_insert
  else
    highlight clear StatusLine
    silent exec s:slhlcmd
    redraw
  endif
endfunction

function! s:GetHighlight(hi)
  redir => hl
  exec 'highlight '.a:hi
  redir END
  let hl = substitute(hl, '[\r\n]', '', 'g')
  let hl = substitute(hl, 'xxx', '', '')
  return hl
endfunction

""""""""""""""""""""""""""""""
"全角スペースを表示
""""""""""""""""""""""""""""""
"コメント以外で全角スペースを指定しているので、scriptencodingと、
"このファイルのエンコードが一致するよう注意！
"強調表示されない場合、ここでscriptencodingを指定するとうまくいく事があります。
"scriptencoding cp932
function! ZenkakuSpace()
  highlight ZenkakuSpace cterm=underline ctermfg=darkgrey gui=underline guifg=darkgrey
  "全角スペースを明示的に表示する
  silent! match ZenkakuSpace /　/
endfunction

if has('syntax')
  augroup ZenkakuSpace
    autocmd!
    autocmd VimEnter,BufEnter * call ZenkakuSpace()
  augroup END
endif

""""""""""""""""""""""""""""""
"grep,tagsのためカレントディレクトリをファイルと同じディレクトリに移動する
""""""""""""""""""""""""""""""
if exists('+autochdir')
  "autochdirがある場合カレントディレクトリを移動
  set autochdir
else
  "autochdirが存在しないが、カレントディレクトリを移動したい場合
  au BufEnter * execute ":silent! lcd " . escape(expand("%:p:h"), ' ')
endif

"----------------------------------------
" 各種プラグイン設定
"----------------------------------------
"----------------------------------------
" NeoBundle 設定
"----------------------------------------
if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim
  call neobundle#begin(expand('~/.vim/bundle/'))
endif
"neobundle自体をneobundleで管理
NeoBundleFetch 'Shougo/neobundle.vim'
  "NeoBundleのインストール
  nnoremap <silent> <Space>bi :<C-u>NeoBundleInstall<CR>
  "NeoBundleのアップデート
  nnoremap <silent> <Space>bu :<C-u>NeoBundleUpdate<CR
  "NeoBundleのクリーン
  nnoremap <silent> <Space>bc :<C-u>NeoBundleClean<CR>

"補完
NeoBundle 'Shougo/neocomplcache'
  "起動時に有効化
  let g:neocomplcache_enable_at_startup=1
  "ポップアップメニューで表示される候補の最大数
  let g:neocomplcache_max_list = 10
  "シンタックスをキャッシュするときの最小文字長
  let g:neocomplcache_min_syntax_length = 3
  "大文字が入力されるまで大文字小文字の区別を無視する
  let g:neocomplcache_enable_smart_case = 1
  "ファイルやスクリプトの名前の補完
  let g:neocomplcache_enable_auto_delimiter = 1
  "大文字補完の有効化。例えばArgumentsExceptionならAE。
  let g:neocomplcache_enable_camel_case_completion = 1
  "アンダーバー補完の有効化。例えばpublic_htmlならp_h。
  let g:neocomplcache_enable_underbar_completion = 1
  "現在選択している候補を確定します
  inoremap <expr><CR>  pumvisible() ? neocomplcache#close_popup() : "\<CR>"
  "補完候補を閉じる
  inoremap <expr><C-h> pumvisible() ? neocomplcache#smart_close_popup() : "\<C-h>"
  inoremap <expr><BS> pumvisible() ? neocomplcache#smart_close_popup() : "\<C-h>"
  "現在の補完をキャンセルして閉じる
  inoremap <expr><C-e> pumvisible() ? neocomplcache#cancel_popup() : ""
  "前回行われた補完をキャンセルし補完した文字を消す
  inoremap <expr><C-g> neocomplcache#undo_completion()
  "補完候補の中から、共通する部分を補完
  inoremap <expr><C-l> pumvisible() ? neocomplcache#complete_common_string() : "\<Tab>"
NeoBundle 'Shougo/neosnippet'
  imap <C-k> <Plug>(neosnippet_expand_or_jump)
  smap <C-k> <Plug>(neosnippet_expand_or_jump)
  xmap <C-k> <Plug>(neosnippet_expand_target)
NeoBundle 'Shougo/neosnippet-snippets'
  "スニペット作成
  noremap <silent> ns :NeoComplCacheEditSnippets<CR>
  "スニペットを保存するディレクトリ
  let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'
"インデントに色を付けて表示
NeoBundle 'nathanaelkane/vim-indent-guides'
  "色を指定する
  "let g:indent_guides_auto_colors = 0
  "autocmd VimEnter, Colorscheme * :hi IndentGuidesOdd   guibg = red   ctermbg = 3
  "autocmd VimEnter, Colorscheme * :hi IndentGuidesEven  guibg = green ctermbg = 4
  "起動時に有効
  let g:indent_guides_enable_on_vim_startup = 1
  "表示幅
  let g:indent_guides_guide_size = 1
  "使用しないファイルタイプ
  let g:indent_guides_exclude_filetypes = ['help', 'nerdtree']
"ステータスラインを綺麗に
NeoBundle 'Lokaltog/vim-powerline'
"自動で括弧などを閉じる
NeoBundle 'Townk/vim-autoclose'
"括弧などで文字を囲うのを便利に
NeoBundle 'tpope/vim-surround'
"IDEっぽくする
NeoBundle 'Shougo/vimproc.vim', {
\ 'build' : {
\     'windows' : 'tools\\update-dll-mingw',
\     'cygwin' : 'make -f make_cygwin.mak',
\     'mac' : 'make -f make_mac.mak',
\     'linux' : 'make',
\     'unix' : 'gmake',
\    },
\ }
if version >= 703
  NeoBundle 'Shougo/unite.vim'
    "The prefix key.
    nnoremap    [unite]   <Nop>
    nmap    <Space>u [unite]
    "unite.vim keymap
    let g:unite_source_history_yank_enable = 1
    nnoremap <silent> [unite]u :<C-u>Unite<Space>file<CR>
    nnoremap <silent> [unite]g :<C-u>Unite<Space>grep<CR>
    nnoremap <silent> [unite]f :<C-u>Unite<Space>buffer<CR>
    nnoremap <silent> [unite]b :<C-u>Unite<Space>bookmark<CR>
    nnoremap <silent> [unite]a :<C-u>UniteBookmarkAdd<CR>
    nnoremap <silent> [unite]m :<C-u>Unite<Space>file_mru<CR>
    nnoremap <silent> [unite]h :<C-u>Unite<Space>history/yank<CR>
    nnoremap <silent> [unite]r :<C-u>Unite -buffer-name=register register<CR>
    nnoremap <silent> [unite]c :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
    nnoremap <silent> ,vr :UniteResume<CR>
    "インサートモードで開始する
    let g:unite_enable_start_insert = 1
    "grepの代わりにagを使う
    if OSTYPE == "Darwin\n"
      let g:unite_source_grep_command = 'ag'
    endif
    let g:unite_source_grep_default_opts = '--nocolor --nogroup'
    let g:unite_source_grep_max_candidates = 200
    let g:unite_source_grep_recursive_opt = ''
    " unite-grepの便利キーマップ
    vnoremap /g y:Unite grep::-iRn:<C-R>=escape(@", '\\.*$^[]')<CR><CR>
endif
NeoBundle 'Shougo/neomru.vim'
NeoBundle 'szw/vim-tags'
NeoBundle 'vim-scripts/taglist.vim'
  "set tags = tags
  "ctagsのコマンド
  if OSTYPE == "Darwin\n"
    let Tlist_Ctags_Cmd = "/usr/local/bin/ctags"
  elseif OSTYPE == "Linux\n"
    let Tlist_Ctags_Cmd = "/usr/bin/ctags"
  endif
  "現在表示中のファイルのみのタグしか表示しない
  let Tlist_Show_One_File = 1
  "右側にtag listのウィンドウを表示する
  let Tlist_Use_Right_Window = 1
  "taglistのウインドウだけならVimを閉じる
  let Tlist_Exit_OnlyWindow = 1
  "\lでtaglistウインドウを開いたり閉じたり出来るショートカット
  map <silent> <leader>l :TlistToggle<CR>
"キーを押す回数で挿入文字が変わる
NeoBundle 'kana/vim-smartchr'
  inoremap <buffer> <expr> <S-=> smartchr#loop(' + ', '+')
  inoremap <buffer> <expr> - smartchr#loop(' - ', '-')
  inoremap <buffer> <expr> , smartchr#loop(', ', ',')
  inoremap <buffer> <expr> = smartchr#loop(' = ', ' == ', '=')
"vimを開きながらディレクトリをツリー表示
NeoBundle 'scrooloose/nerdtree'
  let NERDTreeShowHidden  =  1
  nnoremap <silent> <C-e> :NERDTreeToggle<CR>
call neobundle#end()
"未インストールのプラグインがある場合、インストールするかどうかを尋ねる
"NeoBundleCheck

"シンタックスハイライト
syntax on

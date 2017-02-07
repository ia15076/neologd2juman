#!/bin/bash
# usage: bash ./neologd2juman.sh INPUT_neologd
# 今いるディレクトリ内に、dicファイル、intファイル、jumandic.dat、jumandic.patを生成する
# optionで出力ディレクトリを指定しようと思ったが、makepatは、実行した場所にjumandic.datがないとこけるので断念

if [ `uname` = "Darwin" ]; then
    #mac用のコード
    juman_utils_bin="/usr/local/opt/juman/libexec/juman/"
    if [ -e ${juman_utils_bin} ]; then
        :
    else
        juman_utils_bin="/usr/local/libexec/juman/"
    fi
elif [ `uname` = "Linux" ]; then
    #Linux用のコード
    juman_utils_bin="/usr/local/libexec/juman/"
fi


if [ $# -ne 1 ]; then
    echo "[Error] Usage: ./neologd2juman.sh INPUT_neologd [juman-installed-path]"
    exit 1
elif [ $# -eq 1 ]; then
    input_base=`basename $1`
elif [ $# -eq 2 ]; then
    input_base=`basename $1`
    juman_utils_bin=$2
else
    echo "[Error] Usage: ./neologd2juman.sh INPUT_neologd [juman-installed-path]"
    exit 1
fi

binary_path=`dirname $0`

### juman toolsの存在確認をする
if [ -e ${juman_utils_bin}"/makeint" ]; then
    :
else
    echo "[Error] There is NO 'makeint' command of juman at "${juman_utils_bin}
    exit 1
fi

### input_baseのファイル存在確認をする
if [ -e ${input_base} ]; then
    :
else
    echo "[Error] There is NO file at ${input_base}"
    exit 1
fi

echo "Use juman tools in = "$juman_utils_bin
echo 'Start...'

# neologdのmecab形式から、juman形式の辞書に変換
# また、文字数の多すぎるエントリや、絵文字、顔文字等の記号を排除
python3 ${binary_path}/codes/neologd2juman.py < $1 > ./${input_base}.dic

echo 'End Converting mecab-neologd-ipadic into juman format.'

# jumanで利用できる辞書（jumandic.dat、jumandic.pat）にコンパイル
${juman_utils_bin}"makeint" ./${input_base}.dic

# メモリが溢れないようにintファイルを分割
split -l 500000 ./${input_base}.int ./${input_base}.int-

: > jumandic.dat
for int_file in ./${input_base}.int-*
do
  ${juman_utils_bin}"dicsort" ${int_file} >> jumandic.dat
done

${juman_utils_bin}"makepat" ./${input_base}.int

echo 'End Compiling.'
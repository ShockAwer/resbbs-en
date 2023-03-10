#!/usr/bin/perl
# ↑ You can use the "perl" language of the provider you subscribe to.
# path. Generally, "#! /usr/local/bin/perl" or "#! /usr/bin/perl" is fine. (It depends.)

#=======================================================================================
#				resbbs Version 1.1
#=======================================================================================
#日本語コード変換モジュール
require 'jcode.pl';

#-----------------------------------------------------------------
# URL for the website's home page to be linked
$homepage = '/../';
#-----------------------------------------------------------------
#Password for administrator deletion mode
# Administrators, enter the password in the subject field and press the [submit] button.
$password = 'abc123';
#-----------------------------------------------------------------
#掲示板の名前
$title = 'Personal ResBBS Board';
#-----------------------------------------------------------------
#Width of ruled lines in submission form
#Do not show ruled lines if set to 0
$table_border = 1;
#-----------------------------------------------------------------
#Background image files
$bg_gif = '';
#-----------------------------------------------------------------
# BG color
$bg_color = '#000000';
# Color of text
$text_color = '#FFFFFF';
# Link color
$link_color = '#FFFF7A';
#V-link character color
$vlink_color = '#FF8888';
#A-link character color
$alink_color = '#FF0000';
#-----------------------------------------------------------------
#Character, message image file.
#Displayed on the left side of the input form.
$ch_gif = 'ressbbs.gif';
#-----------------------------------------------------------------
#Set symbol for reply Symbol='ul' Number='ol'
$ressmode = 'ol';
#-----------------------------------------------------------------
#Line space in reply article Open = 'on' Do not open = 'off
$space = 'on';
#-----------------------------------------------------------------
# File where the software stores messages
$datafile = 'resbbs.txt';
#=======================================================================================
#			This is the end of the initial setup required.
#=======================================================================================
$reload = "http://$ENV{'SERVER_NAME'}$ENV{'SCRIPT_NAME'}";

#クッキーを格納する名前を設定する
$CookieName = 'resbbs';

$ENV{'TZ'} = "JST-9"; 
@DATE = localtime(time);
$DATE[5] += 1900;
$DATE[4] = sprintf("%02d",$DATE[4] + 1);
$DATE[3] = sprintf("%02d",$DATE[3]);
$DATE[2] = sprintf("%02d",$DATE[2]);
$DATE[1] = sprintf("%02d",$DATE[1]);
$DATE[6] = ('Sun','Mon','Tue','Thur','Wed','Fri','Sat') [$DATE[6]];
$date_now = "$DATE[5]/$DATE[4]/$DATE[3]/($DATE[6]) At $DATE[2] $DATE[1] minutes.";

if ($ENV{'REQUEST_METHOD'} eq "POST") {
	read(STDIN, $QUERY_DATA, $ENV{'CONTENT_LENGTH'});
} else { $QUERY_DATA = $ENV{'QUERY_STRING'}; }
@pairs = split(/&/,$QUERY_DATA);
foreach $pair (@pairs) {
	($name, $value) = split(/=/, $pair);
	$value =~ tr/+/ /;
	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
	$value =~ s/</&lt;/g;
	$value =~ s/>/&gt;/g;
	$value =~ s/\n//g;
	$value =~ s/\,/，/g;
	&jcode'convert(*value,'sjis');
	$QUERY{$name} = $value;
}
if (!open(NOTE,"$datafile")) { &error(bad_file); }
@DATA = <NOTE>;
close(NOTE);
foreach $line (@DATA) {
	($date,$code,$ress,$name,$email,$comment,$subject) = split(/\,/,$line);
	$new = "false";
	if ($ress > 0) { $new = "true"; }
	if ($new eq "false") { push(@NEW,$line); }
}
if ($QUERY{'action'} eq 'regist' && $QUERY{'subject'} eq $password) { &deletemode; }
elsif ($QUERY{'action'} eq 'regist') { &regist; }
elsif ($QUERY{'action'} eq 'delete') { &delete; }
elsif ($QUERY{'pline'} ne '') { &html; }
else { &html; }


#===============================HTMLドキュメントを生成===========================
sub html {
	@DATA = reverse(@DATA);
	#クッキーを取得
	$cookies = $ENV{'HTTP_COOKIE'};

	@pairs = split(/;/,$cookies);
	foreach $pair (@pairs) {
		($name, $value) = split(/=/, $pair);
		$name =~ s/ //g;
		$DUMMY{$name} = $value;
	}
	@pairs = split(/,/,$DUMMY{$CookieName});
	foreach $pair (@pairs) {
		($name, $value) = split(/:/, $pair);
		$COOKIE{$name} = $value;
	}

	#Declare the header of the HTML document
	print "Content-type: text/html\n\n";
	#投稿フォームを作成
	print "<html><head><title>" . $title . "</title></head>\n";
	print "<body bgcolor=$bg_color text=$text_color link=$link_color vlink=$vlink_color alink=$alink_color background=$bg_gif>\n";
	print "<div align=center><center>\n";
	print "<table border=0><tr>\n";
		print "<td valign=top><img src=" . $ch_gif . "><br>\n";
		print "[<a href=$homepage>HomePage</a>]<p>\n";
		print "<em>Articles are sorted from newest.<br>\n";
		print "To reply, click the [REPLY] button and fill in the textbox. <br>\n";
		print "The reply article will be added to the original article. <br>\n";
		print "<br><br></em>\n";
		print "<font color=#FF0000><em>※ Half-width kana characters cannot be used.</em></font></td>\n";
		print "<td>\n";
		print "<form method=POST action=resbbs.cgi>\n";
		print "<input type=hidden name=action value=regist>\n";
		print "<table border=$table_border cellspacing=1>\n";
			print "<tr><td align=center>Name</td>\n";
			print "<td><input type=text size=34 name=name value=" . $COOKIE{'name'} . "></td></tr>\n";
			print "<tr><td align=center>E-mail</td>\n";
			print "<td><input type=text size=34 name=email value=" . $COOKIE{'email'} . "></td></tr>\n";
			print "<tr><td align=center>Title</td>\n";
			#返信の場合は、題名を挿入する
			if ($QUERY{'flags'} eq 'return') {
				$QUERY{'subject'} =~ s/RE://g;
				print "<td><input type=text size=34 name=subject value=RE:" . $QUERY{'subject'} . "></td>\n";
			} else {
				print "<td><input type=text size=34 name=subject></td>\n";
			}
			print "</tr>\n";
			print "<tr><td align=center>Contents</td>\n";
			print "<td align=center><textarea name=comment rows=3 cols=60></textarea><br>\n";
			if ($QUERY{'flags'} eq 'return') {
				print "<input type=submit value=$QUERY{'subject'}Reply>\n";
				print "<input type=hidden name=ress value=$QUERY{'code'}>\n";
			} else { print "<input type=submit value=New Post>\n"; }
			print "</td></tr>\n";
		print "</table>\n";
		print "</form>\n";
	print "</td></tr></table>\n";
	if ($QUERY{'pline'} eq '') { $pline = 0; } else { $pline = $QUERY{'pline'}; }
	#保存されている総データ数を取得
	$end_data = @NEW - 1;
	#１ページに表示するデータ数を今までに表示した数にプラスする
	$page_end = $pline + 9;
	#ページの最後の行が総データ数以上になるそこで終わりにする
	if ($page_end >= $end_data) { $page_end = $end_data; }
	#投稿されている記事を１行ずつ表示する
	foreach ($pline .. $page_end) {
		($date,$code,$ress,$name,$email,$comment,$subject) = split(/\,/,$NEW[$_]);
		#入力通り出力されるようエンターを<br>に換える
		$comment =~ s/\r/<br>/g;
		#１行ごとに返信ボタンを付けるフォームを作成
		print "<form method=POST action=resbbs.cgi>\n";
		print "<table border=1 width=90%>\n";
			print "<tr><td bgcolor=#000088>\n";
			#print "[" . $code . "]\n";
			print "<font color=$link_color size=+2><b><i>$subject</i></b></font>\n";
			print "　Submitter：\n";
			#メールアドレスが記入されていればリンクをつける
			if ($email ne '') { print "<b><a href=mailto:" . $email . ">" . $name . "</a></b>\n"; }
			else { print "<b>" . $name . "</b>\n"; }
			#返信ボタンを付ける
			print "<font size=-1>　Submission Date：" . $date . "</font>　<input type=submit value=Reply><br>\n";
			print "</td></tr>\n";
			print "<tr><td bgcolor=#004400>\n";
			#リロードするときのフラグを「返信」に設定
			print "<input type=hidden name=flags value=return>\n";
			#何行目の返信かを知るためにコードを返す
			print "<input type=hidden name=code value=" . $code . ">\n";
			#サブジェクトを返す
			print "<input type=hidden name=subject value=" . $subject . ">\n";
			print "<blockquote>\n";
				print "<p>$comment</p>\n";
				print "<$ressmode>\n";
				foreach $ressline (@DATA) {
					($da,$co,$re,$na,$em,$com,$su) = split(/\,/,$ressline);
					$com =~ s/\r/<br>/g;
					if ($code eq $re) {
						print "<li><font size=2>re:</font><font size=3>\n";
						#メールアドレスが記入されていればリンクをつける
						if ($em ne '') { print "<b><a href=mailto:" . $em . ">" . $na . "</a></b>\n"; }
						else { print "<b>" . $na . "</b>\n"; }
						print "</font> 3\n";
						print "<font size=2> Submission Date：$da</font><br>\n";
						print "$com</li>\n";
						if ($space eq 'on') { print "<br>　 \n"; }
					}
				}
				print "</$ressmode>\n";
			print "</blockquote>\n";
			print "</td></tr></table>\n";
		print "</form><p>\n";
	}
	print "</center></div>\n";
	#次のページの最初の行番号をこのページの最後の行に１プラスする
	$next_line = $page_end + 1;
	#まだデータが残っていれば次ページのボタンを付ける
	if ($page_end ne $end_data) {
		#次ページのためのフォームを生成
		print "<form method=POST action=resbbs.cgi>\n";
			print "<input type=hidden name=pline value=" . $next_line . ">\n";
			print "<input type=submit value=Next 10 items>\n";
		print "</form>\n";
	}
	print "<p align=right><font size=2><a href=http://www2.inforyoma.or.jp/~terra/>resBBS Ver1.1 by Terra</a></font></p>\n";
	print "</body></html>\n";
	exit;
}

#===============================記事をファイルに書き込むサブルーチン===========================
sub regist {
	#入力されたデータをチェックして、投稿者、コメント、メールアドレスが
	#入力されていなければエラーを出力し、再入力を促す
	if ($QUERY{'name'} eq "")    { &error(bad_name);    }
	if ($QUERY{'comment'} eq "") { &error(bad_comment); }
	#メールアドレスの未記入を許可する場合は、下の行の先頭に「#」をつけて無効にする
	#if ($QUERY{'email'} ne "") { if (!($QUERY{'email'} =~ /(.*)\@(.*)\.(.*)/)) { &error(bad_email); }}
	$ENV{'TZ'} = "GMT"; 
	@date = localtime(time + 30 * 86400);
	$date[5] += 1900;
	$date[3] = sprintf("%02d",$date[3]);
	$date[2] = sprintf("%02d",$date[2]);
	$date[1] = sprintf("%02d",$date[1]);
	$date[0] = sprintf("%02d",$date[0]);
	$wday = ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday') [$date[6]];
	$month = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec') [$date[4]];
	$date_gmt = "$wday, $date[3]\-$month\-$date[5] $date[2]:$date[1]:$date[0] GMT";
	$cook="name\:$QUERY{'name'}\,email\:$QUERY{'email'}";
	print "Set-Cookie: $CookieName=$cook; expires=$date_gmt\n";

	#最大登録数１００件を超えるデータを切り捨てます
	$i = 1;
	foreach $line (@DATA) {
		$i++;
		#99件までのデータを新しい配列に格納
		if ($i <= 99) { push(@new_data,$line); }
	}
	#追加する記事のコードを取得
	$count = @DATA;
	if ($count < 1) {
		#記事がない場合は、コードを１に
		$new_code = 1;
	} else {
		#記事ある場合は、最後に投稿された記事のコードに１プラスする
		($date,$code,$name,$email,$comment,$subject) = split(/\,/,$DATA[0]);
		$new_code = $code + 1;
	}
	#書き込みデータのフォーマットを整えます
	$value = "$date_now\,$new_code,$QUERY{'ress'}\,$QUERY{'name'}\,$QUERY{'email'}\,$QUERY{'comment'}\,$QUERY{'subject'}\n";
	#最後に投稿された記事を先頭に追加する
	unshift(@new_data,$value);
	#データベースファイルを上書きする
	if (!open(NOTE,">$datafile")) { &error(bad_file); }
	print NOTE @new_data;
	close(NOTE);
	#最新のデータを表示するため、リロードします
	print "Location: $reload?\n\n";
	exit;
}

#======================================削除モード=================================
sub deletemode {
	$count = @DATA;
	#登録されている記事が無ければ削除の必要が無いので戻る
	if ($count eq 0) { &html; }
	#HTMLドキュメントのヘッダーを宣言
	print "Content-type: text/html\n\n";
	#投稿フォームを作成
	print "<html><head><title>" . $title . "</title></head>\n";
	print "<body bgcolor=$bg_color text=$text_color link=$link_color vlink=$vlink_color alink=$alink_color background=$bg_gif>\n";
	print "<form action=resbbs.cgi method=POST>\n";
		print "<input type=hidden name=action value=delete>\n";
		print "Delkey：<input type=text size=39 name=delcode>\n";
		print "　<input type=submit value=Delete><br>\n";
		print "<font size=2>You can delete any number of items at the same time, separated by spaces. </font>\n";
	print "</form>\n";
	print "<hr>\n";
	foreach $line (@DATA) {
		($date,$code,$ress,$name,$email,$comment,$subject) = split(/\,/,$line);
		#入力通り出力されるようエンターを<br>に換える
		#$comment =~ s/\r/<br>/g;
		print "<table border=0 width=100%>\n";
		print "<tr>\n";
			print "<td width=5% valign=top>[$code]</td>\n";
			print "<td valign=top>\n";
				print "<font color=$link_color size=+1><b>$subject</b></font>\n";
				print "　投稿者：\n";
				#メールアドレスが記入されていればリンクをつける
				if ($email ne '') { print "<b><a href=mailto:" . $email . ">" . $name . "</a></b>\n"; }
				else { print "<b>" . $name . "</b>\n"; }
				print "<font size=-1>　Submission Date：" . $date . "</font><br>\n";
				print "$comment\n";
			print "</td>\n";
		print "</tr></table>\n";
		print "<hr>\n";
	}
	print "<form action=resbbs.cgi method=POST>\n";
		print "<input type=hidden name=action value=delete>\n";
		print "Delkey：<input type=text size=39 name=delcode>\n";
		print "　<input type=submit value=Delete><br>\n";
		print "<font size=2>You can delete any number of items at the same time, separated by spaces. </font>\n";
	print "</form>\n";
	exit;
}
#======================================削除モード=================================
sub delete {
	@CODE = split(/ /,$QUERY{'delcode'});
	$keycount = @CODE;
	#削除する番号が指定されていなければ戻る
	if ($keycount eq 0) { &html; }
	#データベースファイルを開き、DATA配列に格納します
	if (!open(NOTE,"$datafile")) { &error(bad_file); }
	@DATA = <NOTE>;
	close(NOTE);
	$count = @DATA;
	foreach $line (@DATA) {
		($date,$code,$ress,$name,$email,$comment,$subject) = split(/\,/,$line);
		$match = "false";
		foreach $delcode (@CODE) {
			if ($code eq $delcode) { $match = "true"; }
		}
		if ($match eq "false") { push (@new_data,$line); }
	}
	#データベースファイルを上書きする
	if (!open(NOTE,">$datafile")) { &error(bad_file); }
	print NOTE @new_data;
	close(NOTE);
	print "Location: $reload?\n\n";
	exit;
}
#======================================エラー処理ルーチン=================================
sub error {
	$error = $_[0];
	if ($error eq "bad_file") { $msg = 'File open, input/output failed. '; }
	elsif ($error eq "bad_name") { $msg = 'Poster name is not filled in. '; }
	elsif ($error eq "bad_comment") { $msg = 'Nothing has been entered in the contents field. '; }
	elsif ($error eq "bad_email") {	$msg = 'メールアドレスが不正です。'; }
	else { $msg = 'Processing cannot continue due to an unknown error. '; }
	print "Content-type: text/html\n\n";
	print "<html><head><title>" . $title . "</title></head>\n";
	print "<body bgcolor=$bg_color text=$text_color link=$link_color vlink=$vlink_color alink=$alink_color background=$bg_gif>\n";
	print "<center><font size=5>ＥＲＲＯＲ</font><hr>\n";
	print "<i>" . $msg . "</i><hr>\n";
	print "</center></body></html>\n";
	exit;
}

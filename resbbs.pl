#!/usr/local/bin/perl
#       �����Ȃ����������Ă���v���o�C�_�̢perl����ꂪ�g�p�ł���
#         �p�X���w�肵�܂��B��ʓI�ɢ#!/usr/local/bin/perl��ő��v

#=======================================================================================
#				resbbs Version 1.1
#=======================================================================================
#���{��R�[�h�ϊ����W���[��
require 'jcode.pl';

#-----------------------------------------------------------------
#���Ȃ��̃z�[���y�[�W�ɖ߂邽�߂̂t�q�k
$homepage = 'http://wwwxx.xxxxxxxx.or.jp/~xxxxxx/index.htm';
#-----------------------------------------------------------------
#�Ǘ��ҍ폜���[�h�̃p�X���[�h
#�Ǘ��҂́A�������Ƀp�X���[�h����͂���[���e]�{�^��������
$password = 'abc123';
#-----------------------------------------------------------------
#�f���̖��O
$title = '�p�[�\�i�����X�{�[�h';
#-----------------------------------------------------------------
#���e�t�H�[���̌r���̕�
#�O�ɂ���ƌr����\�����Ȃ�
$table_border = 1;
#-----------------------------------------------------------------
#�o�b�N�O�����h�̉摜�t�@�C��
$bg_gif = '';
#-----------------------------------------------------------------
#�o�b�N�O�����h�J���[
$bg_color = '#000000';
#�e�L�X�g�̕����F
$text_color = '#FFFFFF';
#�����N�����F
$link_color = '#FFFF7A';
#�u�����N�����F
$vlink_color = '#FF8888';
#�`�����N�����F
$alink_color = '#FF0000';
#-----------------------------------------------------------------
#�L�����N�^�[�A���b�Z�[�W�摜�t�@�C��
#���̓t�H�[���̍����ɕ\������܂��B
$ch_gif = 'ressbbs.gif';
#-----------------------------------------------------------------
#�ԐM�̋L����ݒ� �L��='ul' �ԍ�='ol'
$ressmode = 'ol';
#-----------------------------------------------------------------
#�ԐM�L���̍s�ԁ@�J���遁'on' �J���Ȃ���'off'
$space = 'on';
#-----------------------------------------------------------------
#���b�Z�[�W���i�[����f�[�^�x�[�X�t�@�C��
$datafile = 'resbbs.txt';
#=======================================================================================
#			�����ݒ肪�K�v�Ȃ̂͂����܂łł��B
#=======================================================================================
$reload = "http://$ENV{'SERVER_NAME'}$ENV{'SCRIPT_NAME'}";

#�N�b�L�[���i�[���閼�O��ݒ肷��
$CookieName = 'resbbs';

$ENV{'TZ'} = "JST-9"; 
@DATE = localtime(time);
$DATE[5] += 1900;
$DATE[4] = sprintf("%02d",$DATE[4] + 1);
$DATE[3] = sprintf("%02d",$DATE[3]);
$DATE[2] = sprintf("%02d",$DATE[2]);
$DATE[1] = sprintf("%02d",$DATE[1]);
$DATE[6] = ('��','��','��','��','��','��','�y') [$DATE[6]];
$date_now = "$DATE[5]�N$DATE[4]��$DATE[3]��($DATE[6]) $DATE[2]��$DATE[1]��";

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
	$value =~ s/\,/�C/g;
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


#===============================HTML�h�L�������g�𐶐�===========================
sub html {
	@DATA = reverse(@DATA);
	#�N�b�L�[���擾
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

	#HTML�h�L�������g�̃w�b�_�[��錾
	print "Content-type: text/html\n\n";
	#���e�t�H�[�����쐬
	print "<html><head><title>" . $title . "</title></head>\n";
	print "<body bgcolor=$bg_color text=$text_color link=$link_color vlink=$vlink_color alink=$alink_color background=$bg_gif>\n";
	print "<div align=center><center>\n";
	print "<table border=0><tr>\n";
		print "<td valign=top><img src=" . $ch_gif . "><br>\n";
		print "[<a href=$homepage>HomePage</a>]<p>\n";
		print "<em>�V�������e����f�ڂ��Ă��܂��B<br>\n";
		print "�ԐM��[�ԐM]�{�^���������ăR�����g���L�����ĉ������B<br>\n";
		print "�ԐM�L���͌��̋L���ɒǉ�����܂��B<br>\n";
		print "<br><br></em>\n";
		print "<font color=#FF0000><em>�����p�J�i�͎g�p�ł��܂���B</em></font></td>\n";
		print "<td>\n";
		print "<form method=POST action=resbbs.cgi>\n";
		print "<input type=hidden name=action value=regist>\n";
		print "<table border=$table_border cellspacing=1>\n";
			print "<tr><td align=center>�����O</td>\n";
			print "<td><input type=text size=34 name=name value=" . $COOKIE{'name'} . "></td></tr>\n";
			print "<tr><td align=center>E-mail</td>\n";
			print "<td><input type=text size=34 name=email value=" . $COOKIE{'email'} . "></td></tr>\n";
			print "<tr><td align=center>�薼</td>\n";
			#�ԐM�̏ꍇ�́A�薼��}������
			if ($QUERY{'flags'} eq 'return') {
				#���X�̃��X��h�����߁uRE:�v���폜
				$QUERY{'subject'} =~ s/RE://g;
				print "<td><input type=text size=34 name=subject value=RE:" . $QUERY{'subject'} . "></td>\n";
			} else {
				print "<td><input type=text size=34 name=subject></td>\n";
			}
			print "</tr>\n";
			print "<tr><td align=center>���e</td>\n";
			print "<td align=center><textarea name=comment rows=3 cols=60></textarea><br>\n";
			if ($QUERY{'flags'} eq 'return') {
				print "<input type=submit value=$QUERY{'subject'}�֕ԐM>\n";
				print "<input type=hidden name=ress value=$QUERY{'code'}>\n";
			} else { print "<input type=submit value=�V�K���e>\n"; }
			print "</td></tr>\n";
		print "</table>\n";
		print "</form>\n";
	print "</td></tr></table>\n";
	if ($QUERY{'pline'} eq '') { $pline = 0; } else { $pline = $QUERY{'pline'}; }
	#�ۑ�����Ă��鑍�f�[�^�����擾
	$end_data = @NEW - 1;
	#�P�y�[�W�ɕ\������f�[�^�������܂łɕ\���������Ƀv���X����
	$page_end = $pline + 9;
	#�y�[�W�̍Ō�̍s�����f�[�^���ȏ�ɂȂ邻���ŏI���ɂ���
	if ($page_end >= $end_data) { $page_end = $end_data; }
	#���e����Ă���L�����P�s���\������
	foreach ($pline .. $page_end) {
		($date,$code,$ress,$name,$email,$comment,$subject) = split(/\,/,$NEW[$_]);
		#���͒ʂ�o�͂����悤�G���^�[��<br>�Ɋ�����
		$comment =~ s/\r/<br>/g;
		#�P�s���ƂɕԐM�{�^����t����t�H�[�����쐬
		print "<form method=POST action=resbbs.cgi>\n";
		print "<table border=1 width=90%>\n";
			print "<tr><td bgcolor=#000088>\n";
			#print "[" . $code . "]\n";
			print "<font color=$link_color size=+2><b><i>$subject</i></b></font>\n";
			print "�@���e�ҁF\n";
			#���[���A�h���X���L������Ă���΃����N������
			if ($email ne '') { print "<b><a href=mailto:" . $email . ">" . $name . "</a></b>\n"; }
			else { print "<b>" . $name . "</b>\n"; }
			#�ԐM�{�^����t����
			print "<font size=-1>�@���e���F" . $date . "</font>�@<input type=submit value=�ԐM><br>\n";
			print "</td></tr>\n";
			print "<tr><td bgcolor=#004400>\n";
			#�����[�h����Ƃ��̃t���O���u�ԐM�v�ɐݒ�
			print "<input type=hidden name=flags value=return>\n";
			#���s�ڂ̕ԐM����m�邽�߂ɃR�[�h��Ԃ�
			print "<input type=hidden name=code value=" . $code . ">\n";
			#�T�u�W�F�N�g��Ԃ�
			print "<input type=hidden name=subject value=" . $subject . ">\n";
			print "<blockquote>\n";
				print "<p>$comment</p>\n";
				print "<$ressmode>\n";
				foreach $ressline (@DATA) {
					($da,$co,$re,$na,$em,$com,$su) = split(/\,/,$ressline);
					$com =~ s/\r/<br>/g;
					if ($code eq $re) {
						print "<li><font size=2>re:</font><font size=3>\n";
						#���[���A�h���X���L������Ă���΃����N������
						if ($em ne '') { print "<b><a href=mailto:" . $em . ">" . $na . "</a></b>\n"; }
						else { print "<b>" . $na . "</b>\n"; }
						print "</font> ����\n";
						print "<font size=2> ���e���F$da</font><br>\n";
						print "$com</li>\n";
						if ($space eq 'on') { print "<br>�@ \n"; }
					}
				}
				print "</$ressmode>\n";
			print "</blockquote>\n";
			print "</td></tr></table>\n";
		print "</form><p>\n";
	}
	print "</center></div>\n";
	#���̃y�[�W�̍ŏ��̍s�ԍ������̃y�[�W�̍Ō�̍s�ɂP�v���X����
	$next_line = $page_end + 1;
	#�܂��f�[�^���c���Ă���Ύ��y�[�W�̃{�^����t����
	if ($page_end ne $end_data) {
		#���y�[�W�̂��߂̃t�H�[���𐶐�
		print "<form method=POST action=resbbs.cgi>\n";
			print "<input type=hidden name=pline value=" . $next_line . ">\n";
			print "<input type=submit value=����10��>\n";
		print "</form>\n";
	}
	print "<p align=right><font size=2><a href=http://www2.inforyoma.or.jp/~terra/>resBBS Ver1.1 by Terra</a></font></p>\n";
	print "</body></html>\n";
	exit;
}

#===============================�L�����t�@�C���ɏ������ރT�u���[�`��===========================
sub regist {
	#���͂��ꂽ�f�[�^���`�F�b�N���āA���e�ҁA�R�����g�A���[���A�h���X��
	#���͂���Ă��Ȃ���΃G���[���o�͂��A�ē��͂𑣂�
	if ($QUERY{'name'} eq "")    { &error(bad_name);    }
	if ($QUERY{'comment'} eq "") { &error(bad_comment); }
	#���[���A�h���X�̖��L����������ꍇ�́A���̍s�̐擪�Ɂu#�v�����Ė����ɂ���
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

	#�ő�o�^���P�O�O���𒴂���f�[�^��؂�̂Ă܂�
	$i = 1;
	foreach $line (@DATA) {
		$i++;
		#99���܂ł̃f�[�^��V�����z��Ɋi�[
		if ($i <= 99) { push(@new_data,$line); }
	}
	#�ǉ�����L���̃R�[�h���擾
	$count = @DATA;
	if ($count < 1) {
		#�L�����Ȃ��ꍇ�́A�R�[�h���P��
		$new_code = 1;
	} else {
		#�L������ꍇ�́A�Ō�ɓ��e���ꂽ�L���̃R�[�h�ɂP�v���X����
		($date,$code,$name,$email,$comment,$subject) = split(/\,/,$DATA[0]);
		$new_code = $code + 1;
	}
	#�������݃f�[�^�̃t�H�[�}�b�g�𐮂��܂�
	$value = "$date_now\,$new_code,$QUERY{'ress'}\,$QUERY{'name'}\,$QUERY{'email'}\,$QUERY{'comment'}\,$QUERY{'subject'}\n";
	#�Ō�ɓ��e���ꂽ�L����擪�ɒǉ�����
	unshift(@new_data,$value);
	#�f�[�^�x�[�X�t�@�C�����㏑������
	if (!open(NOTE,">$datafile")) { &error(bad_file); }
	print NOTE @new_data;
	close(NOTE);
	#�ŐV�̃f�[�^��\�����邽�߁A�����[�h���܂�
	print "Location: $reload?\n\n";
	exit;
}

#======================================�폜���[�h=================================
sub deletemode {
	$count = @DATA;
	#�o�^����Ă���L����������΍폜�̕K�v�������̂Ŗ߂�
	if ($count eq 0) { &html; }
	#HTML�h�L�������g�̃w�b�_�[��錾
	print "Content-type: text/html\n\n";
	#���e�t�H�[�����쐬
	print "<html><head><title>" . $title . "</title></head>\n";
	print "<body bgcolor=$bg_color text=$text_color link=$link_color vlink=$vlink_color alink=$alink_color background=$bg_gif>\n";
	print "<form action=resbbs.cgi method=POST>\n";
		print "<input type=hidden name=action value=delete>\n";
		print "�폜�R�[�h�F<input type=text size=39 name=delcode>\n";
		print "�@<input type=submit value=�폜><br>\n";
		print "<font size=2>�X�y�[�X�ŋ�؂��Ă����ł������ɍ폜���邱�Ƃ��ł��܂��B</font>\n";
	print "</form>\n";
	print "<hr>\n";
	foreach $line (@DATA) {
		($date,$code,$ress,$name,$email,$comment,$subject) = split(/\,/,$line);
		#���͒ʂ�o�͂����悤�G���^�[��<br>�Ɋ�����
		#$comment =~ s/\r/<br>/g;
		print "<table border=0 width=100%>\n";
		print "<tr>\n";
			print "<td width=5% valign=top>[$code]</td>\n";
			print "<td valign=top>\n";
				print "<font color=$link_color size=+1><b>$subject</b></font>\n";
				print "�@���e�ҁF\n";
				#���[���A�h���X���L������Ă���΃����N������
				if ($email ne '') { print "<b><a href=mailto:" . $email . ">" . $name . "</a></b>\n"; }
				else { print "<b>" . $name . "</b>\n"; }
				print "<font size=-1>�@���e���F" . $date . "</font><br>\n";
				print "$comment\n";
			print "</td>\n";
		print "</tr></table>\n";
		print "<hr>\n";
	}
	print "<form action=resbbs.cgi method=POST>\n";
		print "<input type=hidden name=action value=delete>\n";
		print "�폜�R�[�h�F<input type=text size=39 name=delcode>\n";
		print "�@<input type=submit value=�폜><br>\n";
		print "<font size=2>�X�y�[�X�ŋ�؂��Ă����ł������ɍ폜���邱�Ƃ��ł��܂��B</font>\n";
	print "</form>\n";
	exit;
}
#======================================�폜���[�h=================================
sub delete {
	@CODE = split(/ /,$QUERY{'delcode'});
	$keycount = @CODE;
	#�폜����ԍ����w�肳��Ă��Ȃ���Ζ߂�
	if ($keycount eq 0) { &html; }
	#�f�[�^�x�[�X�t�@�C�����J���ADATA�z��Ɋi�[���܂�
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
	#�f�[�^�x�[�X�t�@�C�����㏑������
	if (!open(NOTE,">$datafile")) { &error(bad_file); }
	print NOTE @new_data;
	close(NOTE);
	print "Location: $reload?\n\n";
	exit;
}
#======================================�G���[�������[�`��=================================
sub error {
	$error = $_[0];
	if ($error eq "bad_file") { $msg = '�t�@�C���̃I�[�v���A���o�͂Ɏ��s���܂����B'; }
	elsif ($error eq "bad_name") { $msg = '�j�b�N�l�[�����L������Ă��܂���B'; }
	elsif ($error eq "bad_comment") { $msg = '�R�����g���L������Ă��܂���B'; }
	elsif ($error eq "bad_email") {	$msg = '���[���A�h���X���s���ł��B'; }
	else { $msg = '�����s���̃G���[�ŏ������p���ł��܂���B'; }
	print "Content-type: text/html\n\n";
	print "<html><head><title>" . $title . "</title></head>\n";
	print "<body bgcolor=$bg_color text=$text_color link=$link_color vlink=$vlink_color alink=$alink_color background=$bg_gif>\n";
	print "<center><font size=5>�d�q�q�n�q</font><hr>\n";
	print "<i>" . $msg . "</i><hr>\n";
	print "</center></body></html>\n";
	exit;
}

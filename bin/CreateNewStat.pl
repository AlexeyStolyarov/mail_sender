#!perl
#
# Written by Alexey A Stolyarov ICQ: 274-333-174
#
$VERSION        =       q{1.1};

# ���������� ������ ������������ ���������.
use locale;

use lib q{..\lib};
use MIME::Lite;
use Net::SMTP;
use SentFiles;

#==================================================================================
$debug_mode       = 1; # ���������� ����� ������
#$debug_mode2      = 1; # ��  ������ dialup
#$debug_level      = 1; # 0 - ������ [+]  |  1 - ������ ��
#==================================================================================

require qq{functions.pl};
require qq{config.pl};

# my $cp = `chcp`;
# �������� ����� �� 'Active code page: 866'
#    $cp =~ s/\D//g;
# �������� ������������� Windows CP.
#    qx{chcp 1251};
#==================================================================================
%DateChange  =  qw..;
# ������ ������ ��������
%tmp_file_list = read_state();


map {print qq{\n$_ =>}.$tmp_file_list{$_}} keys %tmp_file_list;
# ����� ��������� ������
write_state(%tmp_file_list);

# ����� ��������� ������������ �����


# ��������������� �������� CODEPAGE.
# qx(\@chcp $cp);




__DATA__

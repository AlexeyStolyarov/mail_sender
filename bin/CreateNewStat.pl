#!perl
#
# Written by Alexey A Stolyarov ICQ: 274-333-174
#
$VERSION        =       q{1.1};

# Используем модуль национальной поддержки.
use locale;

use lib q{..\lib};
use MIME::Lite;
use Net::SMTP;
use SentFiles;

#==================================================================================
$debug_mode       = 1; # используем левые днаные
#$debug_mode2      = 1; # Не  делать dialup
#$debug_level      = 1; # 0 - только [+]  |  1 - писать всё
#==================================================================================

require qq{functions.pl};
require qq{config.pl};

# my $cp = `chcp`;
# Выделяем число из 'Active code page: 866'
#    $cp =~ s/\D//g;
# Временно устанавливаем Windows CP.
#    qx{chcp 1251};
#==================================================================================
%DateChange  =  qw..;
# Делаем снимок файлегов
%tmp_file_list = read_state();


map {print qq{\n$_ =>}.$tmp_file_list{$_}} keys %tmp_file_list;
# пишем состояние файлов
write_state(%tmp_file_list);

# пишем состояние отправленных фалов


# Восстанавливаем исходную CODEPAGE.
# qx(\@chcp $cp);




__DATA__

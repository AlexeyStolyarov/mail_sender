#==================================================================================
#**************************       config              *****************************
#==================================================================================
$OK_FLAG          = q{OK};
$wrk_dir          = ($debug_mode)?        q{..\test}     :       q{c:\PTK PSD\Post\Post\Out};
#$wrk_dir          = q{c:\PTK PSD\Post\Post\Out};
$file_mask_send   = q{751\.000$};    # отправка
$file_mask_rsvd   = q{_00\.751$};    # нужна для sort_mail()
$file_mask_rsvd2  = q{000\.751$};    # нужна для sort_mail()
$separator        = q{#};

$log_dir          = q{..\log};
$files_state      = qq{$log_dir\\files_state.log.txt};
$log_file         = qq{$log_dir\\sent_mail.log.txt};
$sent_files_state = qq{$log_dir\\sent_files_state.txt};
$pid_file         = qq{$log_dir\\mail_sender.pid};

$dialup_conn      = ($debug_mode)?        q{com-line}    :       q{guobr};
$dialup_login     = ($debug_mode)?        q{guest}       :       q{kb751};
$dialup_passw     = ($debug_mode)?        q{guest}       :       q{7BIhg$P!};
$dialup_phone     = ($debug_mode)?        q{92479293}    :       q{92680711};
#$dialup_iface     = ($debug_mode)?        q{eth4}        :       q{PPP};
$dialup_iface     = $dialup_conn;
$eth_iface        = q{192.168.0.5};

#==================================================================================

$mail_smtphost    = ($debug_mode)?        q{mail.reserv.chel.su} : q{192.168.9.253}; # q{twin1.cbr.ru};


$mail_path        = qq{..\\zerat};
$mail_prog        = qq{$mail_path\\zerat.exe};

$mail_from        = ($debug_mode)?        q{lamer@reserv.chel.su}     : q{kb751@chelext.chel.cbr.ru};
$mail_to          = ($debug_mode)?        q{lamer@reserv.chel.su}     : q{GUOBR@chel.cbr.ru};
$mail_to_debug    = ($debug_mode)?        q{lamer@reserv.chel.su}: q{bozov@reserv.chel.su};
$mail_subj        = ($debug_mode)?        q{DEBUG: REPORTS_751  }: q{REPORTS_751 (Bank Reserv)};
$mail_subj_debug  = q{DEBUG: REPORTS_751 (Bank Reserv)};
$mail_msg         = qq{Здравствуйте, \nпримите новые отчёты от Банк "РЕЗЕРВ" - Челябинск};
$mail_files_path  = $wrk_dir;



$mail_error_host  = q{mail.reserv.chel.su};
$mail_error_to    = q{root@reserv.chel.su};
#$mail_error_to    = q{Alexey Stolyarov <root@reserv.chel.su>, Bozov S.E. <bozov@reserv.chel.su>, Golubev A <alex@reserv.chel.su>};
# ???!!! Странно.. посылает только 2-м первым... !!!???
$mail_error_from  = q{cron_daemon_at_backup@reserv.chel.su};
$mail_error_subj  = qq{ERROR! Cant dialup to $mail_smtphost};
$mail_error_msg   = qq{Внимание!! \n Не могу дозвонится до $mail_smtphost по телефону $dialup_phone \n (Соединение $dialup_conn)} ;



$pop3_host         = ($debug_mode)?        q{pop.mail.ru}       : q{192.168.9.253};
$pop3_user         = ($debug_mode)?        q{dodik78}           : q{kb751};
$pop3_pass         = ($debug_mode)?        q{230578}            : q{P5/n]DFI};
$pop3_flags        = q{messages:"leave" extract:"yes"};

# ??!!! Zerat провильно складывает почту только при абсолютных путях
$rcvd_mail_temp_store = q{C:\WebServers\cron\mail_processing\tmp};
$rcvd_mail_store      = ($debug_mode)? q{..\store} : q{C:\PTK PSD\Post\CB};



#==================================================================================

my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
$SummerTume   = ($isdst)? 1 : 0;

#==================================================================================




























1;
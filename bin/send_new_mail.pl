#!perl
#
# Written by Alexey A Stolyarov ICQ: 274-333-174
#
$VERSION        =       q{1.2};
# [+]  Поправка налетнее время
# $VERSION      =       q{1.1};
# [+]  Исправлен глюк: если во время работы скрипта файлег обновлялся - то он пропускался


# Используем модуль национальной поддержки.
use locale;

use lib q{..\lib};
use MIME::Lite;
use Net::SMTP;
use SentFiles;

#==================================================================================
#$debug_mode       = 1; # используем левые днаные
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

open(LOG, ">>$log_file") or die $!;

pid_file_start();

$sent_files               = new SentFiles();
$sent_files->{file_state} = $sent_files_state;
$sent_files->read();

# Делаем снимок файлегов
%tmp_file_list = read_state();

# считываем предыдущий снимок
open(FF, $files_state) or die($!);
    while(<FF>)
     {
        next if m/^(\n|\r)*$/;
        chomp;
        my ($f, $d) = split /$separator/;
        $file_list{$f} = $d
     }
close FF;



#opendir DD, $wrk_dir or die("Cant find $wrk_dir");
#     while (my $file = readdir DD)
#     {
#     next if $file !~ /$file_mask_send/ ;
#     if (not exists $file_list{$file} or $file_list{$file} ne  file_mtime(qq{$wrk_dir\\$file}) )
#        {
#             push @diff, $file
#        }
#     }
#closedir DD;
# Вместо того, чтобы работать непосредственно с каталогом - работаем с его снимком..
# и удобнее и логичнее :-)
map{
     push @diff, $_  if (not exists $file_list{$_} or $file_list{$_} ne  $tmp_file_list{$_} )
   } keys %tmp_file_list;


if ($#diff > -1 or $sent_files->size() != 0)
        {
        if( $OK_FLAG eq dialup_start($dialup_conn, $dialup_login, $dialup_passw, $dialup_phone) )
          {

          if ( $sent_files->size() != 0)
              {
                  if ( $OK_FLAG eq get_mail() )
                     {
                       my @rsvd_files = sort_mail();
                       my @rsvd_files_to_log;
                       for my $x ( keys %{$sent_files->{files}})
                       {
                        map { push @rsvd_files_to_log, $_ if m/^$x.*/} @rsvd_files
                       }

                      if($#rsvd_files_to_log > -1)
                       {
                        print_log( qq{[ <- ] Сегвачёг  прислал ответ: }. join(", ", @rsvd_files_to_log).qq{. Схадилъ, забралъ} );
                         for(@rsvd_files)
                            {
                            $sent_files->test($_);
                            }
                         $sent_files->del_recived();
                         $sent_files->show() if $debug_level == 1;
                        }
                     }
                    else
                     {
                        dialup_stop();
                        print_log( qq{[ !! ] Чёрт!! Не могу получить почту с $pop3_host} );
                        send_mail_alert();
                        _exit();
                     }
                } # // get mail

          if($#diff > -1)
          {
                if($#diff > -1 and $OK_FLAG eq send_mail(@diff))
                   {
                   print_log( qq{[ -> ] Буагага!! Новые файлеги: }. join(", ", @diff).qq{. Файлеги улятели на  $mail_to } );
                   $sent_files->add(@diff);
                   dialup_stop();
                   send_mail_debug(@diff);
                   }
                else
                   {
                   dialup_stop();
                   print_log( qq{[ !! ] Ёб%#ный в рот! Не могу отправить на $mail_smtphost} );
                   send_mail_alert();
                   _exit();
                   }
          }

          dialup_stop();
          } # end if( $OK_FLAG eq dialup_start
        else
          {
          print_log( qq{[ !! ] Вот блядство! Не могу дозвонится до $mail_smtphost по телефону $dialup_phone (Соединение $dialup_conn)} );
          send_mail_alert();
          _exit();
          }
        } # end if( $OK_FLAG eq dialup_start...
else
        {
        print_log( qq{[ - ] Ничегошеньки нового :-(} ) if ($debug_level == 1);
        }




# пишем состояние файлов
write_state(%tmp_file_list);

# пишем состояние отправленных фалов
$sent_files->write();

# Восстанавливаем исходную CODEPAGE.
# qx(\@chcp $cp);
_exit();


__DATA__

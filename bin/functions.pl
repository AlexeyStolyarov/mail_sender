#==================================================================================
#**************************       functions           *****************************
#==================================================================================
sub read_state
{
my %files;
opendir DD, $wrk_dir or die("Cant fine $wrk_dir");
     while (my $file = readdir DD)
     {
     next if $file !~ /$file_mask_send/ ;
     $files{$file} = file_mtime(qq{$wrk_dir\\$file});
     }
closedir DD;
return %files;
}
#==================================================================================
sub write_state
{
my %files = @_;

open OUT, qq{>$files_state}  or die $!;
     print OUT map{ qq{$_$separator$files{$_}\n}}  keys %files;
close OUT;
}

#==================================================================================

sub print_log
{
my $x = shift;
print qq!\n$x!;
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

        $year += 1900;
        $mon  += 1;
        $min=sprintf("%.02d",$min);
        $hour=sprintf("%.02d",$hour);

        $prefix = "[$mday-$mon-$year][$hour:$min] :";

($debug_mode)? print  LOG qq{\n$prefix \{DEBUG MODE\}:$x}
             : print  LOG qq{\n$prefix $x};
}

#==================================================================================

sub dialup_start
{
# 1 - ok

return $OK_FLAG if $debug_mode2;

my ($conn, $login, $passw, $phone) = @_ ;



     (defined $phone)? qx{ rasdial.exe $conn $login $passw /PHONE:$phone }
                     : qx{ rasdial.exe $conn $login $passw};
     return $OK_FLAG if dialup_test($dialup_iface) eq $OK_FLAG;


     print     q{DIALUP_START:ERROR_DIALUP};
#            die("DIALUP_START:ERROR_DIALUP");
     return    q{DIALUP_START:ERROR_DIALUP}

}

sub dialup_test
{
# 1 - ok. ** - error
return q{MISSING_ARGS}  if $#_          == -1;
return $OK_FLAG         if $debug_mode2 ==  1;

my $ifconf;
my $ppp = shift;

$ifconf =  qx{ipconfig};

return $OK_FLAG if $ifconf =~ m/.*$ppp.*/g;
return q{MIISING_CONNECTION};
}


sub dialup_stop
{
     return $OK_FLAG if $debug_mode2;
     qx{ rasdial.exe /disconnect };
}

#==================================================================================

sub send_mail
{
my $state = mail_sender($dialup_iface, $mail_smtphost, $mail_from, $mail_to, $mail_subj, $mail_msg, @_);

print_log q{SEND_MAIL:ERROR} if($OK_FLAG ne $state );
return $state;

print qq{\n\n$mail_command  \n \$state = $state\n} if $debug_mode2;
}

sub send_mail_debug
{
my $state = mail_sender($eth_iface, $mail_error_host, $mail_from, $mail_to_debug, $mail_subj_debug, $mail_msg, @_ );

print_log q{SEND_MAIL_DEBUG:ERROR} if($OK_FLAG ne $state );
return $state;
}

#==================================================================================
sub send_mail_alert
{
my $state  = mail_sender($eth_iface, $mail_error_host, $mail_error_from, $mail_error_to, $mail_error_subj,$mail_error_msg );

print_log q{SEND_MAIL_ALERT:ERROR} if($OK_FLAG ne $state );
return $state;
}


sub mail_sender
{
my $state = dialup_test(shift);
if ( $OK_FLAG ne $state)
    {
    print_log q{MAIL_SENDER:MISSING_CONNECTION};
    return $state;
    }

my ($_host, $_from, $_to, $_subj, $_msg, @_files ) = @_;

#my $mail_command = qq{$mail_prog host:$_host from:"$_from" to:"$_to" subject:"$_subj" type:multipart/mixed \$boun "Content-Type: text/plain; charset=windows-1251" $_smg};

### Create the multipart "container":
    my $msg = MIME::Lite->new(
                 From    =>$_from,
                 To      =>$_to,
#                 Cc      =>'some@other.com, some@more.com',
                 Subject =>$_subj,
                 Type    =>'multipart/mixed'
                 );

### Add the text message part:
### (Note that "attach" has same arguments as "new"):
#    $msg->attach(Type     =>'TEXT',
#                 Data     =>"Here's the GIF file you wanted"
#                 );

   if($#_files > -1)
       {
       for (@_files)
                {
                 $msg->attach
                 (Type          =>'image/gif',
                 Path           =>qq{$mail_files_path\\$_},
                 Filename       =>qq{$_},
                 Disposition    => 'attachment'
                 );

                }

       }

#    $str = $msg->as_string;
#    $str = $msg->header_as_string;
#    $str = $msg->body_as_string;
     ### Add the image part:
     print qq{\n}.$msg->header_as_string() if $debug_level == 1;

     MIME::Lite->send('smtp', $_host, Timeout=>60);

     $msg->send() or die();  # or {  print_log q{MAIL_SENDER:MISSING_CONNECTION}; return $state; }

     return $OK_FLAG
}


sub get_mail
{

return q{POP3:MIISING_CONNECTION} if dialup_test($dialup_iface) ne $OK_FLAG;


my $pop3_command = qq{$mail_prog pop3host:"$pop3_host" user:"$pop3_user" pass:"$pop3_pass" localdir:"$rcvd_mail_temp_store" $pop3_flags};

system($pop3_command);
#  256 error
#  0 - ok
#print $pop3_command;

print_log q{POP3:MAIL_RECIEVE_ERROR} if $? != 0;
return  ($? == 0)? $OK_FLAG : $?;
}


sub sort_mail
{
my @res;
opendir DD, $rcvd_mail_temp_store or die("Cant find $rcvd_mail_temp_store");
     while (my $file = readdir DD)
     {
     for( keys %{ $sent_files->{files}  } )
        {
        if($file =~ m/$_($file_mask_rsvd|$file_mask_rsvd2)/ )
           {
            rename(qq{$rcvd_mail_temp_store\\$file},qq{$rcvd_mail_store\\$file});
            push @res, $file
           }
        }

     }
     print qx{del $rcvd_mail_temp_store\\*\.* /q};

closedir DD;

return @res;
}

sub file_mtime
{
my $mtime = (stat shift)[9] - $SummerTume * 3600;
$mtime =~s/^(\d+)/localtime($1)/e;
return $mtime;
}


#==================================================================================
sub pid_file_start
{
if ( -e $pid_file)
   {
   print_log("Запуск второй копии скрипта?! Нах%№я спрашивается!!");
   close LOG;
   exit(0);
   }
else
   {
    open(PID, ">$pid_file") or die $!;
   }
}
#==================================================================================

sub pid_file_stop
{
if ( ! -e $pid_file)
   {
   print_log("А-а-а-а-а-а-а! какой %№#@ удалил мой pid файл ($pid_file) !? ]:-> ");
   close LOG;
   exit(0);
   }
else
   {
    close PID;
    qx{del $pid_file /q};
   }
}





sub _exit
{

pid_file_stop();

close LOG;

# Восстанавливаем исходную CODEPAGE.
# qx(\@chcp $cp);
exit(0);

}






































1;
#
# WRITTEN BY AKEXEY.A.STOLYAROV
#
package SentFiles;
#require  Exporter;
#@ISA = qw(Exporter);
#@EXPORT = qw|new showdata setdata|;
my $divider       = q{#};


my $file_sa_mask   = q{^sa.*};
my $file_sent_pref = q{_00.751};
my $file_sent_pref2= q{000.751};

my $state_default = q{FILE_SENT};
my $state_done100 = q{FILE_RECIVED_OK};
my $state_done    = q{RECIVED:_00};
my $state_done2   = q{RECIVED:000};
my $OK_FLAG       = q{OK};


#=====================================================================
sub new{
my $class  =    shift;
my $self   =    {};

 bless $self, $class;

$this->{files}          = {};
$this->{file_state}     = undef;

return $self;
}

#=====================================================================


sub read
{
my    $self = shift;

if ( ! -e $self->{file_state} )
{
        open(FILE, qq[>>$self->{file_state}] ) or die $!;
        close FILE;
}

open(FILE, $self->{file_state} ) or die $!;
        while(<FILE>)
        {
        chomp;
        next if m/^(\s|\t|\n|\r)*$/;
        my($k, $v) = split($divider);
        $self->{files}->{$k} = $v;
        }
close FILE;
}



sub write
{
my $self = shift;

open(FILE, qq[>$self->{file_state}] ) or die $!;
        for( keys  %{ $self->{files} })
        {
        print FILE qq[$_$divider$self->{files}->{$_}\n]
        }
close FILE;
}


sub show
{
my $self = shift;
        for( sort keys %{ $self->{files}} )
        {
        print qq[\n:$_=>$self->{files}->{$_}:]
        }
}


sub add
{
my $self = shift;

return if not @_;

my @arg  = @_;

if( $#arg > 0)
  { #array
  for (@arg)
        {
        s/(\w{5}).*$/$1/;
        $self->{files}->{$_} = $state_default;
        }
  }
else
  {
        $arg[0] =~ s/(\w{5}).*$/$1/;
        $self->{files}->{$arg[0]} = $state_default;
  }

}


sub remove
{
my $self = shift;

return if not @_;
my @arg  = @_;

if( $#arg > 0)
  { #array
  for (@arg) {
             s/(\w{5}).*$/$1/;
             delete $self->{files}->{$_}      if  $self->{files}->{$_} eq $state_done100
             }
  }
else
  {
             $arg[0] =~ s/(\w{5}).*$/$1/;
             delete $self->{files}->{$arg[0]} if  $self->{files}->{$_} eq $state_done100
  }

}



sub size
{
my $self  = shift;
my $rez   = keys %{$self->{files}};

    for(keys %{$self->{files}})
    {
     $rez += 1 if $self->{files}->{$_} ne $state_default
    }

return $rez;
}

#
#
# Проверка пришедших файлов..
#
#
sub test
{
my  $self  = shift;
my  $file  = shift;
my  $key   = $file;
    $key   =~ s/(\w{5}).*$/$1/; # из имени файла извлекаем ключ хэша

return if not exists  $self->{files}->{$key} or $self->{files}->{$key} eq $state_done100;

if ($file =~ m/$file_sa_mask/ )
   { # sa* file
    if( $file  eq $key.$file_sent_pref2 ) { $self->{files}->{$key} = $state_done100 }
    else { return }
   }
else
   { # not sa* file
     if($self->{files}->{$key} eq $state_default)
     # Если state_default, то в зависимости от ключ+000.751 <> файлу назначаем state
      {
        $self->{files}->{$key} = $state_done  if $key.$file_sent_pref  eq $file;
        $self->{files}->{$key} = $state_done2 if $key.$file_sent_pref2 eq $file;
      }
      else
      {
      # Если state eq 000.751 и ключ+_00.751 eq имя файла
       if ( $self->{files}->{$key} eq $state_done2 and $file eq $key.$file_sent_pref  )
         {
         $self->{files}->{$key} = $state_done100;
         return;
         }
        # Если state eq _00.751 и ключ+000.751 eq имя файла
       elsif ( $self->{files}->{$key} eq $state_done  and $file eq $key.$file_sent_pref2 )
         {
         $self->{files}->{$key} = $state_done100;
         return;
         }
      }
   }

}


# удаляем записи со статусом RESIVED
# можно было это делать и через test(). но так удобней. можно смотреть промежуточные результаты
# через show()
sub del_recived
{
my  $self  = shift;
for (keys %{ $self->{files} })
    {  delete $self->{files}->{$_} if $self->{files}->{$_} eq $state_done100 }

}











1;


__DATA__


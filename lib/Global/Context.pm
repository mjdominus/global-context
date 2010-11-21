use strict;
use warnings;
package Global::Context;

use Global::Context::Env::Basic;
use Global::Context::StackFrame::Trivial;

our $Object;

use Sub::Exporter -setup => {
  exports    => [
    ctx_init =>
    ctx_push =>
  ],
  collectors => { '$Context' => \'_export_context_glob' },
};

sub _export_context_glob {
  my ($self, $value, $data) = @_;

  my $name;
  $name = $value->{'-as'} || 'Context';
  $name =~ s/^\$//;

  my $sym = "$data->{into}::$name";

  {
    no strict 'refs';
    *{$sym} = *Global::Context::Object;
  }

  return 1;
}

sub ctx_init {
  my ($arg) = @_;
  confess("context has already been initialized") if $Object;

  $Object = Global::Context::Env::Basic->new($arg)->with_pushed_frame(
    Global::Context::StackFrame::Trivial->new({
      description => Carp::shortmess("context initialized"),
      ephemeral   => 1,
    }),
  );

  return $Object;
}

sub ctx_push {
  my ($frame) = @_;

  $frame = { description => $frame } unless ref $frame;

  $frame = Global::Context::StackFrame::Trivial->new($frame)
    unless Scalar::Util::blessed($frame);

  return $Object->with_pushed_frame($frame);
}

1;

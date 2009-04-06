use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	   => 'RFC::RFC822::Address',
    'VERSION_FROM' => 'lib/RFC/RFC822/Address.pm', # finds $VERSION
    'PREREQ_PM'    => {Parse::RecDescent => '1.52'},
);

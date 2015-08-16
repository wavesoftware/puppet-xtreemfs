# Internal class
class xtreemfs::internal::configure::augeas::verify {
  if $::augeasversion < '1.0.0' {
    fail("xtreemfs puppet module requires an augeas instalation >= 1.0.0, actual version is: ${::augeasversion}")
  }
}
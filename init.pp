class basic_yum_repo {

  # configure the repo we want to use
  yumrepo { 'company_app_repo':
    enabled  => 1,
    descr    => 'Local repo holding company application packages',
    baseurl  => 'http://repos.example.org/apps',
    gpgcheck => 0,
  }

}

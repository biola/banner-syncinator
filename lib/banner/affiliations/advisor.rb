module Banner
  class Advisor < Banner::Person
    include Banner::NonEmployee

    SQL_ALL = "SELECT p.* FROM bsv_lum_advisor_role a, bgv_personal_info p WHERE a.advisor_pidm = p.pidm AND id NOT LIKE 'X%' AND id NOT LIKE 'Z%'"
    SQL_ONE = "SELECT p.* FROM bsv_lum_advisor_role a, bgv_personal_info p WHERE a.advisor_pidm = p.pidm and id = :1"
  end
end

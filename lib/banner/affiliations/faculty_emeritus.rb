module Banner
  class FacultyEmeritus < Employee
    include Banner::NonEmployee

    SQL_ALL = "select b.* from bpv_former_employees a
                join bgv_personal_info b on b.pidm = a.pidm
                where emeritus='Y'"

    SQL_ONE = "select b.* from bpv_former_employees a
                join bgv_personal_info b on b.pidm = a.pidm
                where emeritus='Y'
                and id = :1"
  end
end

module Banner
  class Employee < Banner::Person
    SQL_ALL = "SELECT * FROM bpv_current_employees WHERE (employee = 'Y' OR faculty = 'Y') AND job_ct > 0"
    SQL_ONE = "SELECT * FROM bpv_current_employees WHERE (employee = 'Y' OR faculty = 'Y') AND job_ct > 0 AND id = :1"

    ATTRS = ATTRS + [:pay_type, :department, :title, :office_phone, :job_ct, :full_time, :employee_type]

    default_readers({
      pay_type:       :PAYID,
      department:     :ORG_DESC,
      title:          :TITLE,
      office_phone:   :DIR_EXT

      # TODO: Not sure what to do with the commented out columns below
      #employee_type: :EMP_TYPE, # not used (I think)
      #org:           :ORG,
      #job_type:      :JOB_TYPE,
      #fac_type:      :FAC_TYPE,
      #alt_ext:       :ALT_EXT # TODO: create new "alternate office phone" or something type
    })

    def job_ct
      raw_attributes[:JOB_CT].try :to_i
    end

    def full_time
      raw_attributes[:FT_PT] == 'F'
    end

    def employee_type
      payid = raw_attributes[:PAYID]
      ft_pt = raw_attributes[:FT_PT]

      TYPE_MAP[payid] || TYPE_MAP[ft_pt] || "Unknown (#{ft_pt})"
    end

    private

    TYPE_MAP = {
      '03' => 'Student Worker',
      'P' => 'Part-Time',
      'F' => 'Full-Time',
      'O' => 'Other'
    }
  end
end

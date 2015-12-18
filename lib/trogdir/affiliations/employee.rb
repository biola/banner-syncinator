module Trogdir
  class Employee < Trogdir::Person
    ATTRS = superclass::ATTRS + [:pay_type, :department, :title, :office_phone, :job_ct, :full_time, :employee_type]

    default_readers({
      pay_type:       :pay_type,
      full_time:      :full_time,
      employee_type:  :employee_type,
      department:     :department,
      title:          :title,
      job_ct:         :job_ct
    })

    def office_phone
      find(:phones, :office)[:number]
    end

    def office_phone_id
      find(:phones, :office)[:id]
    end

    # TODO: alt office phone or whatever
  end
end

module Trogdir
  class Employee < Trogdir::Person
    ATTRS = superclass::ATTRS + [:pay_type, :department, :title, :job_type, :office_phone, :full_time, :employee_type]

    default_readers({
      pay_type:       :pay_type,
      full_time:      :full_time,
      employee_type:  :employee_type,
      department:     :department,
      title:          :title,
      job_type:       :job_type # TODO: should this be here?
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
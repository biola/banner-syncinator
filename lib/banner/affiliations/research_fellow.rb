module Banner
  class ResearchFellow < Employee
    SQL_ALL = "SELECT * FROM bpv_current_employees WHERE research_fellow = 'Y'"
    SQL_ONE = "SELECT * FROM bpv_current_employees WHERE research_fellow = 'Y' AND id = :1"
  end
end

module Banner
  class AcceptedStudent < Banner::Person
    include Banner::NonEmployee

    SQL_ALL =
      %{
        SELECT
        DISTINCT
          PIDM, ID, LNAME, FNAME, MNAME, PNAME, STREET1, STREET2, CITY,
          STATE, ZIP, NATION, EMAIL, GENDER, CONFID, SSN, DOB,
          EMAIL_PERS, UDCID
        FROM bsv_trogdir_accepted
      }
    SQL_ONE =
      %{
        SELECT
        DISTINCT
          PIDM, ID, LNAME, FNAME, MNAME, PNAME, STREET1, STREET2, CITY,
          STATE, ZIP, NATION, EMAIL, GENDER, CONFID, SSN, DOB,
          EMAIL_PERS, UDCID
        FROM bsv_trogdir_accepted
        WHERE id = :1
      }
  end
end

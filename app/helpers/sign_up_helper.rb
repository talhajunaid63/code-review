module SignUpHelper
  def lead_sources
    [
      ["Google Search", "Google Search"],
      ["Facebook", "Facebook"],
      ["Instagram", "Instagram"],
      ["Friend", "Friend"],
      ["Other", "Other"]
    ]
  end

  def birth_year(years_to_go_back=110)
    current_year = Time.now.year
    (0..years_to_go_back).map do |to_subtract|
      year = (current_year - to_subtract)
      [year, year]
    end
  end

  def birth_month
      [
        ['January','1'],
        ['Febraury','2'],
        ['March','3'],
        ['April','4'],
        ['May','5'],
        ['June','6'],
        ['July','7'],
        ['August','8'],
        ['September','9'],
        ['October','10'],
        ['November','11'],
        ['December','12']
      ]
  end

  def birth_day
      [
        ['01','1'],
        ['02','2'],
        ['03','3'],
        ['04','4'],
        ['05','5'],
        ['06','6'],
        ['07','7'],
        ['08','8'],
        ['09','9'],
        ['10','10'],
        ['11','11'],
        ['12','12'],
        ['13','13'],
        ['14','14'],
        ['15','15'],
        ['16','16'],
        ['17','17'],
        ['18','18'],
        ['19','19'],
        ['20','20'],
        ['21','21'],
        ['22','22'],
        ['23','23'],
        ['24','24'],
        ['25','25'],
        ['26','26'],
        ['27','27'],
        ['28','28'],
        ['29','29'],
        ['30','30'],
        ['31','31']
      ]
  end
end

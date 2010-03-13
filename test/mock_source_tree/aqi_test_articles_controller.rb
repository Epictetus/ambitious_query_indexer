class AqiTestArticlesController
  def new
    AqiTestArticle.new
  end
  
  def find
    AqiTestArticle.find_by_id(1)
  end
  
  def obscured_find
    a = AqiTestArticle.find(:all)
    a.find_by_id(2)
  end
end
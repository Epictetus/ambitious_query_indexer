class ArticlesController
  def new
    Article.new
  end
  
  def find
    Article.find_by_id(1)
  end
  
  def obscured_find
    a = Article.find(:all)
    a.find_by_id(2)
  end
end
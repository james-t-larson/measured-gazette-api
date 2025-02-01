module Articles
  class Generate
    def self.perform(limit = nil)
      prepped_groups = []
      Category.all.each do |category|
        groups = EventRegistry::DataPreperation.prepare(category)
        prepped_groups = prepped_groups + groups
      end

      mutex = Mutex.new
      mutex.synchronize do
        prepped_groups.each do |group|
          FetchAndSaveArticlesJob.perform_later(group)
        end
      end

      if DateTime.now.beginning_of_day < ExternalArticle.last.created_at
        articles = ExternalArticle.last_batch_published
        articles = articles.first(limit) if limit
        articles.each do |article|
          GenerateAndSaveArticlesJob.perform_later(article)
        end
      end
    end
  end
end

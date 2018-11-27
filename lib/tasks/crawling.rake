namespace :crawling do
  JOB_METHOD = "perform_now"

  def logger
    Rails.logger
  end

  def build_file_name(job_file)
    'crawling/' + File.basename(job_file, '.rb')
  end

  desc "クローリングを行います"
  task run: :environment do
    begin
      Dir.glob(Rails.root.join('app', 'jobs', 'crawling', '*')).each do |job_file|
        job_name = build_file_name job_file
        job_class = job_name.camelize
        next if job_class == "Crawling::BaseJob"

        job_class.constantize.send JOB_METHOD
      end
    rescue => e
      ExceptionNotifier.notify_exception(e, env: Rails.env)
    end
  end
end
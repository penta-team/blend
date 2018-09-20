namespace :rp do
  desc "apply ridgepole"
  task apply: :environment do
    ridgepole('--apply', "--file #{schema}")

    # Prf::PrfUpdater.fetch_activerecord_conf
  end

  namespace :test do
    desc "apply:test ridgepole"
    task apply: :environment do
      ridgepole('--apply', "--file #{schema}", "--env test")
    end
  end

  desc "show diff"
  task :diff, :environment do
    ridgepole('--diff', "#{config} #{schema}")
  end

  desc "export current db to Schemafile"
  task :export, :environment do
    ridgepole('--export', "--output #{schema}")
  end

  def config
    Rails.root.join('config/database.yml')
  end

  def schema
    Rails.root.join('db/Schemafile')
  end

  def ridgepole(*options)
    command = ['bundle exec ridgepole', "--config #{config} --env #{Rails.env}"]
    system [command, options].join(' ')
    make_scheme_rb
  end

  def make_scheme_rb
    `bundle exec rake db:schema:dump`
  end
end

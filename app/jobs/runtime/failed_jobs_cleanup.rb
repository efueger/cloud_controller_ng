module VCAP::CloudController
  module Jobs
    module Runtime
      class FailedJobsCleanup < VCAP::CloudController::Jobs::CCJob
        attr_accessor :cutoff_age_in_days

        def initialize(cutoff_age_in_days)
          @cutoff_age_in_days = cutoff_age_in_days
        end

        def perform
          old_delayed_jobs = if Delayed::Job.db.database_type == :mssql
                               Delayed::Job.
                                 where(Sequel.lit('FAILED_AT IS NOT NULL')).
                                 where(Sequel.lit('FAILED_AT >= RUN_AT')).
                                 where(Sequel.lit('RUN_AT < DATEADD(DAY, -?, CURRENT_TIMESTAMP)', cutoff_age_in_days.to_i))
                             else
                               Delayed::Job.
                                 where(Sequel.lit('failed_at is not null')).
                                 where(Sequel.lit('failed_at >= run_at')).
                                 where(Sequel.lit("run_at < CURRENT_TIMESTAMP - INTERVAL '?' DAY", cutoff_age_in_days.to_i))
                             end
          logger = Steno.logger('cc.background')
          logger.info("Cleaning up #{old_delayed_jobs.count} Failed Delayed Jobs")

          old_delayed_jobs.delete
        end

        def job_name_in_configuration
          :failed_jobs
        end

        def max_attempts
          1
        end
      end
    end
  end
end
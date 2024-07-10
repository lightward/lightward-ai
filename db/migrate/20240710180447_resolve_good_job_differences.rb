# frozen_string_literal: true

class ResolveGoodJobDifferences < ActiveRecord::Migration[7.1]
  def change
    change_table(:good_jobs) do |t|
      t.uuid(:locked_by_id)
      t.datetime(:locked_at)
    end

    change_table(:good_job_executions) do |t|
      t.uuid(:process_id)
      t.interval(:duration)
    end

    change_table(:good_job_processes) do |t|
      t.integer(:lock_type, limit: 2)
    end

    add_index(
      :good_jobs,
      [:priority, :scheduled_at],
      order: { priority: "ASC NULLS LAST", scheduled_at: :asc },
      where: "finished_at IS NULL AND locked_by_id IS NULL",
      name: :index_good_jobs_on_priority_scheduled_at_unfinished_unlocked,
    )
    add_index(
      :good_jobs,
      :locked_by_id,
      where: "locked_by_id IS NOT NULL",
      name: "index_good_jobs_on_locked_by_id",
    )
    add_index(:good_job_executions, [:process_id, :created_at], name: :index_good_job_executions_on_process_id_and_created_at)
  end
end

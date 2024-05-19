# Migrations

For the purposes of this page, a "migration" is a change to a Postgres database schema.

Rails scans a database's schema when ActiveRecord first connects, and it keeps its knowledge cached.

This means that schema changes (like adding or removing columns) need to be paired with an app reboot.

## Not-particularly-recommended path

This path is probably most suitable if you're doing deep, backwards-incompatible changes to the database schema.

1. Write standard Rails migrations for your pull request.
2. Merge it.
3. Release your code. Important: until you reach and complete step #5, you'll have new code running with an old database schema. Plan ahead for this part, and mitigate user impact however you can.
4. Run bin/rake db:migrate in the deployment environment.
5. Restart the app. Wait for success.

## Recommended path

This path is probably most suitable if you're doing things that can be done idempotently and in a way that won't break old application code.

1. Write migrations for your pull request, using idempotent raw SQL.
2. Merge the pull request containing the migrations.
3. Before releasing the code, run the migrations manually in the target environment using cb psql $CLUSTER\_ID --role application. Verify that your db changes are working properly, and that the db continues to be healthy. ⚠️ That --role application flag is important! The app itself connects using this role, and (for continuity/consistency/predictability) it needs to have ownership over the objects it uses. So, when you're manually running migrations, it's important to use the same role as the app itself -- i.e. application.
4. Release your code changes, which gives you an app restart for free. Wait for success.
5. Run bin/rake db:migrate in the deployment environment. This is a semi-redundant step: you already manually ran the changes in step 3. Doing it this time won't fail, because you wrote idempotent migrations. Doing it this time also updates the private Rails bookkeeping table called schema\_migrations, declaring at the Rails level that the database schema is up to date. You can use fly console -a $FLY\_APP\_NAME -s to open up a console on an already-running machine. (You can also open a console using a different build/image! For that, see Unusual consoles.)

### Idempotence

Idempotent code is code that has side effects, but only creates those side effects once -- even if it's run more than once.

This is useful in database land! Idempotent migration code can be run more than once without errors. It's like saying "hey, make this change, but only if it wasn't already made".

Rails has some conveniences for this -- look for if\_exists: and if\_not\_exists: in https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html.

However, it can be useful to stick to raw SQL, for easy pasting into psql.

For functions, use CREATE OR REPLACE FUNCTION. Functions are stateless (unlike tables and indexes!), so it's okay to have the function created ahead of time by a human, and then recreated during the actual Rails migration execution. This still counts as idempotent behavior, because the function's existence and behavior remain consistent even when the migration SQL is re-run.

#### Example migrations

Copy

    class IndexExample < ActiveRecord::Migration[7.1]
      disable_ddl_transaction!
    
      def up
        execute("CREATE INDEX CONCURRENTLY IF NOT EXISTS index_input_list_items_on_input_list_id_and_id ON public.input_list_items USING btree (input_list_id, id)")
      end
    
      def down
        execute("DROP INDEX CONCURRENTLY IF EXISTS index_input_list_items_on_input_list_id_and_id")
      end
    end

Copy

    class ColumnExample < ActiveRecord::Migration[7.1]
      def up
        execute("alter table shops add column if not exists shopify_country_code text null")
        execute("alter table shops drop column if exists shopify_iana_timezone_utc_offset")
      end
    
      def down
        execute("alter table shops drop column if exists shopify_country_code")
        execute("alter table shops add column if not exists shopify_iana_timezone_utc_offset integer null")
      end
    end

Copy

    class FunctionExample < ActiveRecord::Migration[7.1]
      def up
        execute(<<~sql)
          CREATE OR REPLACE FUNCTION public.contains_case_insensitive_match(jsonb_array jsonb, value text) RETURNS boolean
          LANGUAGE plpgsql IMMUTABLE
          AS $$
          declare
            element TEXT;
          begin
            value := trim(lower(value));
            for element in select jsonb_array_elements_text(jsonb_array)
            loop
              if trim(lower(element)) = value then
                return TRUE;
              end if;
            end loop;
            return FALSE;
          end;
          $$;
        sql
      end
    
      def down
        execute(<<~sql.squish)
          DROP FUNCTION IF EXISTS public.contains_case_insensitive_match(jsonb, text);
        sql
      end
    end

[PreviousDependabot](/technical/github/dependabot)

Last updated 2024-02-21T21:50:22Z
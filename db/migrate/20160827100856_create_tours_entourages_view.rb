class CreateToursEntouragesView < ActiveRecord::Migration
  def up
    sql = <<-SQL
      CREATE VIEW feeds AS
        SELECT id,
        status,
        title,
        entourage_type,
        user_id,
        latitude,
        longitude,
        number_of_people,
        created_at,
        updated_at
      FROM entourages

      UNION ALL

      SELECT
        DISTINCT ON (id)
        id,
        CASE WHEN status=0 THEN 'ongoing' WHEN status=1 THEN 'closed' WHEN status=2 THEN 'freezed' END AS "status",
        '' AS "TITLE",
        tour_type,
        user_id,
        tp.longitude,
        tp.latitude,
        number_of_people,
        created_at,
        updated_at
      FROM tours
      LEFT OUTER JOIN (
         SELECT latitude, longitude, tour_id
         FROM tour_points
      ) tp ON tp.tour_id = tours.id
      ORDER BY id ASC
    SQL

    execute(sql)
  end

  def down
    execute('DROP VIEW feeds')
  end
end

import psycopg2


def questions(cur):
	query = 'SELECT id, question FROM questions'
	cur.execute(query)
	qs = []
	rows = cur.fetchall()
	for row in rows:
		if len(row) < 2:
			raise Exception('each row in query response must have at least 2 columns')
		q = {
			'question_id':row[0],
			'question': row[1]
		}
		qs.append(q)
	return qs

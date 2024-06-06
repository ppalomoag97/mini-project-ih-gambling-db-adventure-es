import pandas as pd




df = pd.read_excel('dataset/SQL Test Data.xlsx' ,'Student_School')



#df['AccountNo'] = df['AccountNo'].str.strip()


print(f"""
      CREATE TABLE Student (
      {df.columns[0]} INT,
      {df.columns[1]} VARCHAR(255),
      {df.columns[2]} VARCHAR(255)
       )
      """)



df1_list = []
for i in range(len(df)):
    temp = (tuple(df.iloc[i,7:10]))

    df1_list.append(temp)

#with open('output.txt', 'w') as sql:
print(f"""
      INSERT INTO School VALUES  ({[ value for value in df1_list]})

      """)








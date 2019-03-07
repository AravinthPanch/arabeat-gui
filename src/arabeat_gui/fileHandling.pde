
//File Handling 
PrintWriter log_writer;
BufferedReader log_reader;
Boolean create_log = true; 
Boolean read_log = false;
int log_delay = 10;
String logFile = "";

String getTimeStamp(){
  int day = day();
  int month = month();
  int hour = hour();
  int minute = minute();
  int second = second();
  String TimeStamp = day + "_"+ day + "_"+ month+ "_"+ hour+ "_"+ minute+ "_"+ second;
  return(TimeStamp);
}

void initalize_log_writer(){
  if(create_log){
    log_writer = createWriter(getTimeStamp()+"_data"); 
  }
}

void initalize_log_reader(String file_name){
  if(read_log){
    log_reader = createReader(file_name);  
  }
}

// Read Byte
int read_log(){
  if(read_log){
    try{
      int data = log_reader.read();
      println(data);
      delay(log_delay);
      return data;
    }catch (Exception e) {
      e.printStackTrace();
    }
  }
  return 0;
}

// This writes the data into the file 
void write_log(int data){
  if(create_log){
    log_writer.write(data);
  }
}

void flush_log(){
  if(create_log){
    log_writer.flush();
  }
}

void close_log(){
  if(create_log){
    log_writer.close();
  }
}


//File Handling 
PrintWriter log_writer;
BufferedReader log_reader;
Boolean create_log = true; 
Boolean read_log = false;
int log_delay = 10;

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
    log_writer = createWriter("data_"+getTimeStamp()); 
  }
}

void initalize_log_reader(){
    selectInput("Select a file to process:","logSelected");
}

void logSelected(File selection){
  if(selection == null){
    println("File was not Selected");
  }
  else{
    println(selection.getAbsolutePath());
    log_reader = createReader(selection.getName());
    read_log = true;
  }
}

// Read Byte
int read_log(){
  if(read_log){
    try{
      int data = log_reader.read();
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

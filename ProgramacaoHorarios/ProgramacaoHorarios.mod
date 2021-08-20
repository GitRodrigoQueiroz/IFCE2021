{int} I= {1,2,3,4,5,6,7,8,9,10,11,12}; 
{int} J= {1,2,3,4,5}; // j
{string} M= {"SEG - QUA", "TER - QUI", "QUA - SEX", "SEG - QUI", "TER - SEX"}; 
{string} G={};	// LABORATÓRIOS
{string} W={};	
{string} P={}; 
{string} S={}; 
{string} C={}; 
{string} Cs[S]; 
{string} Sm= {}; 
{string} St= {}; 
{string} Sn= {}; 
{string} S_1C= {}; 
{string} S_2C= {}; 
{string} S_4C= {}; 
{string} Sp[P];
{string} Sg[G];
{string} S_20;
{string} S_40;
int A[P][M];
int n1= 1000;
int n2=0; 
int n3=0; 

tuple tuplaDADOS_PROFESSORES{
	string PROFESSOR;
	string PREFERENCIA;
}
{tuplaDADOS_PROFESSORES} DADOS_PROFESSORES={};

tuple tuplaDADOS_TURMAS{
	string TURMA;
	string NOME;
	string CURRICULOS;
	string CURSO;
	string TURNO;
	string CREDITOS;
	string PROFESSOR;
	string N_PREVISTO_INSCRITOS;
	string LAB_EXIGIDO;
}
{tuplaDADOS_TURMAS} DADOS_TURMAS={};

tuple tuplaDADOS_ESPACOS{
		string COD;	
		string BLOCO;
		string DESCRICAO;
		string TIPO;
		string CAP;
		string SITUACAO;
}
{tuplaDADOS_ESPACOS} DADOS_ESPACOS={};

execute{
	for(var p in P){
		for(var m in M){
			A[p][m]=0;			
		}	
	}
}
execute {
	var f=new IloOplInputFile("TURMAS.csv");
	var str=f.readline(); 
	while (!f.eof){
		var str=f.readline();
		var ar=str.split(",");
		DADOS_TURMAS.add(ar[0],ar[1],ar[2],ar[3],ar[4],ar[5],ar[6],ar[7],ar[8]);
		S.add(ar[0]);
	}
	f.close();
}

execute{
	var f=new IloOplInputFile("PROFESSORES.csv");
	var str=f.readline(); 
	while (!f.eof){
		var str=f.readline();
		var ar=str.split(",");
		DADOS_PROFESSORES.add(ar[0],ar[1]);
		P.add(ar[0]);	
	}
	f.close();
}

execute{
	for(var p in DADOS_PROFESSORES){
		A[p.PROFESSOR][p.PREFERENCIA]=1;			
	}
}
execute{
	var f=new IloOplInputFile("CURRICULOS.csv");
	var str=f.readline(); 
	while (!f.eof){
		var str=f.readline();
		var ar=str.split(",");
		C.add(ar[0]);
	}
	f.close();
}

execute {
	var f=new IloOplInputFile("TURMAS.csv");
	var str=f.readline(); 
	while (!f.eof){
		var str=f.readline();
		var ar=str.split(",");
		var aux= ar[2].split("/");
		var i = 0;
		while(true){
			if(aux[i]!= "null"){
				Cs[ar[0]].add(aux[i]);
				i++;			
			}else{
			break;			
			}		
		}
	}
	f.close();
}

execute{
	var f=new IloOplInputFile("ESPACOS.csv");
	var str=f.readline(); 
	while (!f.eof){
		var str=f.readline();
		var ar=str.split(",");
		DADOS_ESPACOS.add(ar[0],ar[1],ar[2],ar[3],ar[4],ar[5]);
	}
	f.close();
}

execute{
  	for(var w in DADOS_ESPACOS){
  	  if(w.TIPO=="LAB" && w.SITUACAO=="A"){
				G.add(w.DESCRICAO);			
			}else if(w.TIPO=="SALA" && w.SITUACAO=="A"){
				W.add(w.COD);	
				if(Opl.intValue(w.CAP)>20){
				  	n3++;
				}else if(Opl.intValue(w.CAP)<=20){
				  	n2++;
				}
			}
  	}
}


execute{
  	for(var s in DADOS_TURMAS){
    	if(s.TURNO=="MANHA"){
    	  Sm.add(s.TURMA);
    	}
    	if(s.TURNO=="TARDE"){
    	  St.add(s.TURMA);
    	}
    	if(s.TURNO=="NOITE"){
    	  Sn.add(s.TURMA);
    	}
    	if(s.CREDITOS=="1"){
    	  S_1C.add(s.TURMA);
    	}
    	if(s.CREDITOS=="2"){
    	  S_2C.add(s.TURMA);
    	}
    	if(s.CREDITOS=="4"){
    	 S_4C.add(s.TURMA); 
    	}
    	if(s.LAB_EXIGIDO!=""){
    	  Sg[s.LAB_EXIGIDO].add(s.TURMA);
    	}
    	if(s.N_PREVISTO_INSCRITOS==">20"){
    	  S_40.add(s.TURMA);
    	}
    	if(s.N_PREVISTO_INSCRITOS=="<20"){
    	  S_20.add(s.TURMA);
    	}
    	Sp[s.PROFESSOR].add(s.TURMA);
  	}
}

dvar boolean x[S][I][J];
dvar boolean y[P][M];
dvar boolean z[P];
dvar boolean n[P];


// FUNÇÃO OBJETIVO

maximize sum(p in P) (z[p] + 100*n[p]);

subject to{
  
  //Transformando a quantidade de dias em restrições
    
  forall(p in P){
    y[p]["SEG - QUI"] +  y[p]["TER - SEX"] <= n1*(-n[p] + 1); 
    y[p]["SEG - QUI"] +  y[p]["TER - SEX"] >= - n1*(-n[p] + 1); 
  }
	
  forall(p in P, m in M){
      A[p][m]<=y[p][m] + n1*(-z[p] + 1);
      A[p][m]>=y[p][m] - n1*(-z[p] + 1);
  }
    
  forall(s in Sm){
    sum(i in 5..12, j in 1..5) x[s][i][j]==0;
  }	
  
  forall(s in St){
    sum(i in 1..4, j in 1..5) x[s][i][j] + 
    sum(i in 9..12, j in 1..5) x[s][i][j] ==0; 
  }	
  
  forall(s in Sn){
    sum(i in 1..8, j in 1..5) x[s][i][j] ==0; 
  }	
  
  forall(s in S_1C){
    sum(i in 1..12, j in 1..5) x[s][i][j] ==1; 
  }	
  
  forall(s in S_2C){
    sum(i in 1..12, j in 1..5) x[s][i][j] ==2; 
  }	
  
  forall(s in S_4C){
    sum(i in 1..12, j in 1..5) x[s][i][j] ==4; 
  }	
  
  forall(j in 1..5, s in S: s in S_2C || s in S_4C){
    x[s][1][j] +  x[s][2][j] != 1;
    x[s][3][j] +  x[s][4][j] != 1;
    x[s][5][j] +  x[s][6][j] != 1;
    x[s][7][j] +  x[s][8][j] != 1;
    x[s][9][j] +  x[s][10][j] != 1;
    x[s][11][j] +  x[s][12][j] != 1; 
  }

  forall(j in 1..5, s in S: s in S_4C){
    sum(i in 1..12) x[s][i][j]<=2;
  }
  
  forall(c in C, i in 1..12, j in 1..5){
    sum(s in S: c in Cs[s]) x[s][i][j]<=1;
  }

  forall(p in P, i in 1..12, j in 1..5){
    sum(s in S: s in Sp[p]) x[s][i][j]<=1;
  }
  
  forall(g in G, i in 1..12, j in 1..5){
    sum(s in S: s in Sg[g]) x[s][i][j]<=1;
  }
 
  forall(i in 1..12, j in 1..5){
    sum(s in S) x[s][i][j]<= n2 + n3;
  }
  
  forall(i in 1..12, j in 1..5){
    sum(s in S: s in S_40) x[s][i][j]<= n3;
  }
  
  forall(p in P){
    sum(m in M) y[p][m]==1;
  }
  
  forall(p in P){
    sum(i in 1..12, j in 4..5, s in S: s in Sp[p]) 
    	x[s][i][j]<= n1*(-y[p]["SEG - QUA"] + 1);
    
    sum(i in 1..12, s in S: s in Sp[p]) 
    (x[s][i][1] + x[s][i][5]) <= n1*(-y[p]["TER - QUI"] + 1);
    
    sum(i in 1..12, j in 1..2, s in S: s in Sp[p]) 
    	x[s][i][j]<= n1*(-y[p]["QUA - SEX"] + 1);
    	
    sum(i in 1..12, s in S: s in Sp[p]) 
    	x[s][i][5]<= n1*(-y[p]["SEG - QUI"] + 1);
    	
    sum(i in 1..12, s in S: s in Sp[p]) 
    	x[s][i][1]<= n1*(-y[p]["TER - SEX"] + 1);
  }
  
  /*
  forall(p in P, j in 1..5){
    sum(s in Sp[p], i in 1..12) x[s][i][j]<=8;
  }	
  
  forall(p in P, j in 1..4){
    (sum(s in Sp[p]) x[s][11][j] + sum(s in Sp[p]) x[s][1][j+1])<=1;
    (sum(s in Sp[p]) x[s][11][j] + sum(s in Sp[p]) x[s][2][j+1])<=1;
    (sum(s in Sp[p]) x[s][12][j] + sum(s in Sp[p]) x[s][1][j+1])<=1;
    (sum(s in Sp[p]) x[s][12][j] + sum(s in Sp[p]) x[s][2][j+1])<=1;
  }


  forall(s in S_4C, j in 1..4){
    sum(i in I) (x[s][i][j]+ x[s][i][j+1])<=2;
  }*/
  
}


execute{
    function turnTuplesetIntoCSV(tupleSet,csvFileName){
    	var f=new IloOplOutputFile(csvFileName);
    	var quote="";
    	var nextline="\\\n";
    	var nbFields=tupleSet.getNFields();
    	for(var j=0;j<nbFields;j++) 
    		f.write(tupleSet.getFieldName(j),";");
    		f.writeln();
    		for(var i in tupleSet){
     			for(var j=0;j<nbFields;j++){
    				var value=i[tupleSet.getFieldName(j)];
   					if (typeof(value)=="string")
   						f.write(quote);
   						f.write(value);
    					if (typeof(value)=="string") 
    						f.write(quote);
    						f.write(";");
    			}
    		f.writeln();
    		}
   		f.close();
    }
}

tuple TuplaRESULTADOS_HORARIOS{
	string TURMA;
	string NOME;
	string CURRICULOS;
	string CURSO;
	string TURNO;
	string CREDITOS;
	string PROFESSOR;
	string NUMERO_PREVISTO_INSCRITOS;
	string LABORATORIO_EXIGIDO;
	int HORARIO_D;
	int HORARIO_S;
}


tuple TuplaRESULTADO_PROFESSORES{
	string PROFESSOR;
	string ALOCACAO;
	string PREFERENCIA;
	string STATUS;
}

{TuplaRESULTADOS_HORARIOS} RESULTADOS_HORARIOS={};
{TuplaRESULTADO_PROFESSORES} RESULTADO_PROFESSORES={};


execute{
  	for(var s in DADOS_TURMAS){
    	for(var i in I){
      		for(var j in J){
        		if(x[s.TURMA][i][j]==1){
          			 RESULTADOS_HORARIOS.add(s.TURMA,
          			 						s.NOME,
          			 						s.CURRICULOS,
          			 						s.CURSO,
          			 						s.TURNO,
          			 						s.CREDITOS,
          			 						s.PROFESSOR,
          			 						s.N_PREVISTO_INSCRITOS,
          			 						s.LAB_EXIGIDO,
          			 						i,
          			 						j);
    			}
      		}
    	}
  	}
}

execute{
	for(var p in DADOS_PROFESSORES){
		for(var m in M){
			if(y[p.PROFESSOR][m]==1){
				if(p.PREFERENCIA==m ){
					RESULTADO_PROFESSORES.add(p.PROFESSOR,m,p.PREFERENCIA,"ATENDIDO");					
				}else{
				RESULTADO_PROFESSORES.add(p.PROFESSOR,m,p.PREFERENCIA,"NÃO ATENDIDO");					
				}	
							
			}		
		}	
	}
}

execute{
    turnTuplesetIntoCSV(RESULTADOS_HORARIOS,"RESULTADOS_HORARIOS.csv");
    turnTuplesetIntoCSV(RESULTADO_PROFESSORES,"RESULTADOS_PROFESSORES.csv");
}





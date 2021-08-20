int n1= 10000;
{int} I={1,2,3,4,5,6,7,8,9,10,11,12};
{int} J= {1,2,3,4,5};
{string} S={};
{string} W={}; 
{string} C={}; 
{string} S_={};
{string} Cs[S]; 
{string} Ssup={};
{string} Ssub={};
{string} Sint={};
{string} S_sup={"T44","T48","T61","T88","T229","T244","T245","T253","T294","T313","T315"};
{string} S_sub={"T320"};
{string} S_int={"T11","T223"};
{string} S40;
{string} W20;// Sala pequena
{string} W40;// Sala grande
{string} Wa;
{string} Wb;
{string} Wc;

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
{TuplaRESULTADOS_HORARIOS} RESULTADOS_HORARIOS= {};

tuple tuplaDADOS_ESPACOS{
		string COD;	
		string BLOCO;
		string DESCRICAO;
		string TIPO;
		int CAP;
		string SITUACAO;
}
{tuplaDADOS_ESPACOS} DADOS_ESPACOS={};

tuple tuplaHORARIOS_D{
	string HORARIO;	
	string TURNO;
}
tuplaHORARIOS_D HORARIOS_D[I]=...;

tuple tuplaHORARIOS_S{
	string DIA;	
}
tuplaHORARIOS_S HORARIOS_S[J]=...;

execute {
	var f=new IloOplInputFile("RESULTADOS_HORARIOS.csv");
	var str=f.readline(); 
	while (!f.eof){
		var str=f.readline();
		var ar=str.split(";");
		if(typeof(ar[0])=="string"){
			RESULTADOS_HORARIOS.add(ar[0],ar[1],ar[2],ar[3],ar[4],ar[5],ar[6],ar[7],ar[8],ar[9],ar[10]);		
			S.add(ar[0]);
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
		DADOS_ESPACOS.add(ar[0],ar[1],ar[2],ar[3],Opl.intValue(ar[4]),ar[5]);
		for(var w in DADOS_ESPACOS){
			if(w.TIPO=="SALA" && w.SITUACAO=="A"){
				W.add(w.COD);		
			}		
		}
		
	}
	f.close();
}

execute{
 	for(var w in DADOS_ESPACOS){
 	  if(w.TIPO=="SALA" && w.SITUACAO=="A" && w.BLOCO=="A"){
 	    Wa.add(w.COD);
 	  }
 	  if(w.TIPO=="SALA" && w.SITUACAO=="A" && w.BLOCO=="B"){
 	    Wb.add(w.COD);
 	  }
 	  if(w.TIPO=="SALA" && w.SITUACAO=="A" && w.BLOCO=="C"){
 	    Wc.add(w.COD);
 	  }
 	  if(w.TIPO=="SALA" && w.SITUACAO=="A" && w.CAP>20){
 	    W40.add(w.COD);
 	  }
 	  if(w.TIPO=="SALA" && w.SITUACAO=="A" && w.CAP<=20){
 	    W20.add(w.COD);
 	  }
 	} 
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
	var f=new IloOplInputFile("CURRICULOS.csv");
	var str=f.readline(); 
	while (!f.eof){
		var str=f.readline();
		var ar=str.split(",");
		C.add(ar[0]);
	}
	f.close();
}

execute{
  for(var s in RESULTADOS_HORARIOS){
 		
		if(s.CURSO == "TIQ" || s.CURSO == "TIE"){
		  Sint.add(s.TURMA);
		}
		if(s.CURSO == "EAS" || s.CURSO == "EC" || s.CURSO == "EPC" 
							|| s.CURSO == "LG" || s.CURSO == "LIQ"){
		  Ssup.add(s.TURMA);
		} 
		if(s.CURSO == "TSE" || s.CURSO == "TMA" || s.CURSO == "TSQ"){
		  Ssub.add(s.TURMA);
		} 
		if(s.CURSO=="OFERTA CONJUNTA"){
		  S_.add(s.TURMA);
		} 
		if(s.NUMERO_PREVISTO_INSCRITOS==">20"){
		  S40.add(s.TURMA);
		} 	
  }
  
}

dvar boolean x[S][W];
dvar boolean y[W][C];
dvar boolean h[S]; 

maximize sum(s in S) h[s];

subject to{
  
  // Restrições fracas
  
  forall(s in S: s in S40){
    sum(w in W: w in W20) x[s][w]<=0 + n1*(1-h[s]);
  }
  
  // Restrições Rígidas
  
  forall(s in S){
    sum(w in W) x[s][w]==1;
  }
  
  forall(i in I, j in J, w in W){
    sum(s in RESULTADOS_HORARIOS: s.HORARIO_D==i && s.HORARIO_S==j) x[s.TURMA][w]<=1;
  }
 
  forall(s in S: s in Ssup){
    sum(w in W: w in Wa && w in Wb) x[s][w]==0;
  }
  forall(s in S: s in S_sup){
    sum(w in W: w in Wa && w in Wb) x[s][w]==0;
  }
  
  forall(s in S: s in Sint){
    sum(w in W: w in Wc) x[s][w]==0;;
  }
  forall(s in S: s in S_int){
    sum(w in W: w in Wc) x[s][w]==0;;
  }
  
  forall(c in C, w in W){
    sum(s in RESULTADOS_HORARIOS: c in Cs[s.TURMA] && s.CURSO != "OFERTA CONJUNTA") x[s.TURMA][w]<= n1* y[w][c];
	
  }
  forall(c in C, w in W){
	n1*(sum(s in RESULTADOS_HORARIOS: c in Cs[s.TURMA] && s.CURSO != "OFERTA CONJUNTA") x[s.TURMA][w])>=  y[w][c];  
  }
  
  forall(c in C){
    sum(w in W) y[w][c]==1;
  }
  
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

tuple TuplaQUADRO_HORARIOS{
	string CHAVE_DE_PESQUISA1;
	string CHAVE_DE_PESQUISA2;
	string CHAVE_DE_PESQUISA3;
	string CHAVE_DE_PESQUISA4;
	string CHAVE_DE_PESQUISA5;
	string TURMA;
	string NOME;
	string DIA;
	string HORARIO;
	string TURNO;
	string PASTA_DE_ORIGEM;
	string PROFESSOR;
	string SALA;
	string LABORATORIO;
}

{TuplaQUADRO_HORARIOS} QUADRO_HORARIOS={};


execute{
	for(var i in RESULTADOS_HORARIOS){
		for(var w in W){
			if(x[i.TURMA][w]==1){
				for(var c in Cs[i.TURMA]){
				  QUADRO_HORARIOS.add(HORARIOS_D[i.HORARIO_D].HORARIO+"-"+HORARIOS_S[i.HORARIO_S].DIA+"-"+HORARIOS_D[i.HORARIO_D].TURNO,
				  					  HORARIOS_S[i.HORARIO_S].DIA+"-"+HORARIOS_D[i.HORARIO_D].HORARIO+"-"+HORARIOS_D[i.HORARIO_D].TURNO+"-"+i.LABORATORIO_EXIGIDO,
				  					  HORARIOS_S[i.HORARIO_S].DIA+"-"+HORARIOS_D[i.HORARIO_D].HORARIO+"-"+HORARIOS_D[i.HORARIO_D].TURNO+"-"+"SALA "+w,
				  					  HORARIOS_S[i.HORARIO_S].DIA+"-"+HORARIOS_D[i.HORARIO_D].HORARIO+"-"+HORARIOS_D[i.HORARIO_D].TURNO+"-"+c,
				  					  HORARIOS_S[i.HORARIO_S].DIA+"-"+HORARIOS_D[i.HORARIO_D].HORARIO+"-"+HORARIOS_D[i.HORARIO_D].TURNO+"-"+i.PROFESSOR,
				  					  i.TURMA,
				  					  i.NOME,
									  HORARIOS_S[i.HORARIO_S].DIA,
									  HORARIOS_D[i.HORARIO_D].HORARIO,
									  HORARIOS_D[i.HORARIO_D].TURNO,
									  c,
									  i.PROFESSOR,
									  "SALA "+w,
									  i.LABORATORIO_EXIGIDO);
				}		
			}		
		}	
	}
}

execute{
    turnTuplesetIntoCSV(QUADRO_HORARIOS,"QUADRO_HORARIOS.csv");

}


function table.randomize(theTable)
	result={}
	while #theTable>0 do
		table.insert(result, theTable.remove(theTable:randomi()))
	end
end

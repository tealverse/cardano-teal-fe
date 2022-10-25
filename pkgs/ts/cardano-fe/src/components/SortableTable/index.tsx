import React, { ReactElement, SetStateAction, useState } from 'react';
import { css, styled } from 'twin.macro';
import { useEffect } from 'react';

export type ColumnCfg<Key> = {
  label: string;
  selector: Key;
  sortable: boolean;
};

type SortableTableProps<Key extends string> = {
  columns: Array<ColumnCfg<Key>>;
  data: TableData<Key>;
};

type TableData<Key extends string> =
  | Array<Record<Key, string | ReactElement | number>>
  | Array<never>;

export const SortableTable = <Key extends string>({
  columns,
  data,
}: SortableTableProps<Key>): ReactElement => {
  const [tableData, setTableData] = useState(data);
  const [sortSelector, setSortSelector] = useState<Key | undefined>();
  const [sortAsc, setSortAsc] = useState<boolean>(true);

  useEffect(() => {
    if (sortSelector) {
      setTableData(sortData(sortSelector, sortAsc, data));
    } else {
      setTableData(data);
    }
  }, [data, sortSelector]);

  return (
    <table>
      <thead>
        <tr>
          {columns.map((col, index) => (
            <TableHead
              key={index}
              col={col}
              setSortSelector={setSortSelector}
            />
          ))}
        </tr>
      </thead>
      <tbody>
        {tableData.length > 0 ? (
          tableData.map((d, index) => (
            <tr key={index}>
              {columns.map((col, index) => (
                <td key={index}>{d[col.selector]}</td>
              ))}
            </tr>
          ))
        ) : (
          <tr>
            <td>No data!</td>
          </tr>
        )}
      </tbody>
    </table>
  );
};

type TableHeadProps<Key extends string> = {
  col: ColumnCfg<Key>;
  setSortSelector: React.Dispatch<SetStateAction<Key | undefined>>;
};

const TableHead = <Key extends string>({
  col,
  setSortSelector,
}: TableHeadProps<Key>) => {
  const { label, selector } = col;
  return (
    <th>
      <NoStyleButton onClick={() => setSortSelector(selector)}>
        {label}
      </NoStyleButton>
    </th>
  );
};

const NoStyleButton = styled.button(() => [
  css`
    border: none;
    outline: none;
    padding: none;
    margin: none;
    width: 100%;
    height: 100%;
    text-align: left;
  `,
]);

const sortData = <K extends string, V>(
  selector: K,
  sortAsc: boolean,
  data_: Array<Record<K, V>>,
  default_?: (arr: Array<Record<K, V>>) => Array<Record<K, V>>,
): Array<Record<K, V>> => {
  const data = [...data_];

  const fst = data[0];
  if (!fst) return data;

  if (data.every(x => typeof x[selector] === 'string')) {
    return data.sort((a, b) =>
      a[selector] < b[selector] ? -1 : a[selector] > b[selector] ? 1 : 0,
    );
  } else if (data.every(x => typeof x[selector] === 'number')) {
    return data
      .sort((a, b) => (a[selector] as number) - (b[selector] as number))
      .reverse();
  }

  return data;
};

import React, { ReactElement } from 'react';

export type ColumnCfg <Key> = {
  label: string;
  selector: Key;
  sortable: boolean;
};

type SortableTableProps<Key extends string> = {
  columns: Array<ColumnCfg<Key>>;
  data: Array<Record<Key, string | ReactElement | number>  > | Array<never>;
};

export const SortableTable = <Key extends string>({
  columns,
  data,
}: SortableTableProps<Key>): ReactElement => {
  return (
    <table>
      <tr>
        {columns.map(col => {
          return <th>{col.label}</th>;
        })}
      </tr>
      {data.length > 0 ? (
        data.map(d => (
          <tr>
            {columns.map(col => {
              const x = d[col.selector];
              return <td>{d[col.selector]}</td>;
            })}
          </tr>
        ))
      ) : (
        <tr>
          <td>No data!</td>
        </tr>
      )}
    </table>
  );
};

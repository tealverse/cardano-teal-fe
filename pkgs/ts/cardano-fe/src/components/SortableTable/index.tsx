import React, { ReactElement } from 'react';

export type ColumnCfg = {
  label: string;
  selector: string;
  sortable: boolean;
};

type SortableTableProps = {
  columns: Array<ColumnCfg>;
  data: Array<{ [key: string]: string | ReactElement | number }>;
};

export const SortableTable = ({
  columns,
  data,
}: SortableTableProps): ReactElement => {
  return (
    <table>
      {columns.map(col => {
        return (
          <tr>
            <th>{col.label}</th>
          </tr>
        );
      })}
      {data.map(d => (
        <tr>
          {columns.map(col => {
            const x = d[col.selector];
            return <td>{d[col.selector]}</td>;
          })}
        </tr>
      ))}
    </table>
  );
};

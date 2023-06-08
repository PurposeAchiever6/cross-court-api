import React from 'react';
import PropTypes from 'prop-types';

const List = ({ items, align, className }) => {
  const alignClasses = (() => {
    switch (align) {
      case 'center':
        return 'items-center';
      case 'top':
      default:
        return 'items-start before:mt-[0.35em]';
    }
  })();

  return (
    <ul className={className}>
      {items.map((item, index) => (
        <li
          key={index}
          className={`flex leading-[1.5em] mb-[1em] before:block before:flex-shrink-0 before:w-[0.75em] before:h-[0.75em] before:mr-[1.5em] before:bg-cc-purple ${alignClasses}`}
        >
          {item}
        </li>
      ))}
    </ul>
  );
};

List.defaultProps = {
  align: 'top',
  className: '',
};

List.propTypes = {
  align: PropTypes.string,
  className: PropTypes.string,
  items: PropTypes.arrayOf(PropTypes.node).isRequired,
};

export default List;